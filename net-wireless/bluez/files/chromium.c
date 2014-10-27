/* Copyright 2014 The Chromium Authors. All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <stdbool.h>
#include <stdint.h>

#include <glib.h>
#include <dbus/dbus.h>
#include <gdbus/gdbus.h>

#include <bluetooth/bluetooth.h>

#include "lib/mgmt.h"
#include "src/adapter.h"
#include "src/dbus-common.h"
#include "src/device.h"
#include "src/error.h"
#include "src/log.h"
#include "src/plugin.h"
#include "src/shared/mgmt.h"

#define DBUS_PATH "/org/bluez"
#define DBUS_PLUGIN_INTERFACE "org.chromium.Bluetooth"
#define DBUS_PLUGIN_DEVICE_INTERFACE "org.chromium.BluetoothDevice"

#define DBUS_BLUEZ_SERVICE "org.bluez"
#define DBUS_OBJECT_MANAGER_INTERFACE "org.freedesktop.DBus.ObjectManager"

#define DBUS_BLUEZ_DEVICE_INTERFACE "org.bluez.Device1"

static struct mgmt *mgmt_if = NULL;

static bool supports_le_services = false;
static bool supports_conn_info = false;

static int interfaces_added_watch_id = 0;
static int interfaces_removed_watch_id = 0;

static gboolean chromium_property_get_supports_le_services(
					const GDBusPropertyTable *property,
					DBusMessageIter *iter, void *data)
{
	dbus_bool_t value = supports_le_services;

	dbus_message_iter_append_basic(iter, DBUS_TYPE_BOOLEAN, &value);

	return TRUE;
}

static gboolean chromium_property_get_supports_conn_info(
					const GDBusPropertyTable *property,
					DBusMessageIter *iter, void *data)
{
	dbus_bool_t value = supports_conn_info;

	dbus_message_iter_append_basic(iter, DBUS_TYPE_BOOLEAN, &value);

	return TRUE;
}

/* Helper functions and struct to find a device and the adapter it belongs to
 * for a given DBus object path.
 */
struct find_device_context {
	const char *device_path;
	struct btd_adapter *adapter;
	struct btd_device *device;
};

static void find_by_path_device_cb(struct btd_device *device, void *data) {
	struct find_device_context *context = data;

	if (strcmp(context->device_path, device_get_path(device)) == 0)
		context->device = device;
}

static void find_by_path_adapter_cb(struct btd_adapter *adapter,
			gpointer user_data) {
	struct find_device_context *context = user_data;

	context->adapter = adapter;
	btd_adapter_for_each_device(adapter, find_by_path_device_cb, context);
}

gboolean find_device_by_path(const char *device_path,
		struct btd_adapter **out_adapter,
		struct btd_device **out_device) {
	struct find_device_context context;

	context.device_path = device_path;
	context.device = NULL;

	adapter_foreach(find_by_path_adapter_cb, &context);
	if (context.adapter == NULL || context.device == NULL)
	    return FALSE;

	*out_adapter = context.adapter;
	*out_device = context.device;
	return TRUE;
}

static void get_conn_info_complete(uint8_t status, uint16_t length,
					const void *param, void *user_data) {
	DBusMessage *msg = user_data;
	DBusMessage *reply;
	const struct mgmt_rp_get_conn_info *rp;
	int16_t rssi, tx_power, max_tx_power;

	if (status == 0) {
		reply = dbus_message_new_method_return(msg);
		if (reply == NULL) {
			dbus_message_unref(msg);
			error("Failed to create dbus reply message.");
			return;
		}

		rp = param;
		rssi = rp->rssi;
		tx_power = rp->tx_power;
		max_tx_power = rp->max_tx_power;

		DBusMessageIter iter;
		dbus_message_iter_init_append(reply, &iter);
		dbus_message_iter_append_basic(&iter, DBUS_TYPE_INT16, &rssi);
		dbus_message_iter_append_basic(
					&iter, DBUS_TYPE_INT16, &tx_power);
		dbus_message_iter_append_basic(
					&iter, DBUS_TYPE_INT16, &max_tx_power);
	} else {
		reply = btd_error_failed(msg, mgmt_errstr(status));
		if (!reply) {
			dbus_message_unref(msg);
			error("Failed to create dbus error reply message.");
			return;
		}
	}

	if (!g_dbus_send_message(btd_get_dbus_connection(), reply))
		error("DBus send failed.");
	dbus_message_unref(msg);
}

static DBusMessage *get_conn_info(DBusConnection *conn,
	        DBusMessage *msg, void *user_data)
{
	const char *device_path = dbus_message_get_path(msg);
	struct btd_adapter *adapter = NULL;
	struct btd_device *device = NULL;
	struct mgmt_cp_get_conn_info cp;

	if (!mgmt_if)
		return btd_error_not_ready(msg);

	if (!supports_conn_info)
		return btd_error_not_supported(msg);

	if (!find_device_by_path(device_path, &adapter, &device))
		return btd_error_does_not_exist(msg);

	if (!btd_device_is_connected(device))
		return btd_error_not_connected(msg);

	memset(&cp, 0, sizeof(cp));
	cp.addr.type = btd_device_get_bdaddr_type(device);
	cp.addr.bdaddr = *device_get_address(device);

	dbus_message_ref(msg);
	if (mgmt_send(mgmt_if, MGMT_OP_GET_CONN_INFO,
			btd_adapter_get_index(adapter), sizeof(cp), &cp,
			get_conn_info_complete, msg, NULL) == 0)
		return btd_error_failed(msg,
				"Failed to send get_conn_info mgmt command");
	return NULL;
}

static const GDBusMethodTable device_methods[] = {
	/* GetConnInfo is a simple DBus wrapper over the get_conn_info mgmt API.
	 */
	{ GDBUS_ASYNC_METHOD("GetConnInfo", NULL,
		GDBUS_ARGS({"TXPower", "y"}, {"MaximumTXPower", "y"}, {"RSSI", "y"}),
		get_conn_info) },
	{ }
};

static bool is_interface_entry_bluez_device(DBusMessageIter *array_iter) {
	int arg_type;
	DBusMessageIter dict_iter;
	char *interface = NULL;

	arg_type = dbus_message_iter_get_arg_type(array_iter);
	if (arg_type == 'e') {
		dbus_message_iter_recurse(array_iter, &dict_iter);
		arg_type = dbus_message_iter_get_arg_type(&dict_iter);
		if (arg_type == 's')
			dbus_message_iter_get_basic(&dict_iter, &interface);
		else
			error("Expected string in InterfaceAdded signal.");

	} else if (arg_type == 's') {
		dbus_message_iter_get_basic(array_iter, &interface);
	} else {
		error("Expected string in InterfaceRemoved signal.");
	}

	return interface &&
			strcmp(interface, DBUS_BLUEZ_DEVICE_INTERFACE) == 0;
}

/* Given an InterfaceAdded or InterfaceRemoved ObjectManager signal, return
 * the object path if it contains the BlueZ device interface; otherwise, return
 * null.
 *
 * The documentation for these ObjectManager signals can be found at
 * http://dbus.freedesktop.org/doc/dbus-specification.html#standard-interfaces-objectmanager
 */
static const char *get_device_path_from_interface_msg(DBusMessage *msg) {
	int arg_type;
	char *object_path = NULL;
	DBusMessageIter args_iter, array_iter;

	dbus_message_iter_init(msg, &args_iter);
	arg_type = dbus_message_iter_get_arg_type(&args_iter);
	if (arg_type != 'o') {
		error("Expected object path in ObjectManager signal.");
		return NULL;
	}

	dbus_message_iter_get_basic(&args_iter, &object_path);
	dbus_message_iter_next(&args_iter);
	if (!object_path)
		return NULL;

	arg_type = dbus_message_iter_get_arg_type(&args_iter);
	if (arg_type != 'a') {
		error("Expected array in ObjectManager signal.");
		return NULL;
	}

	dbus_message_iter_recurse(&args_iter, &array_iter);
	while (dbus_message_iter_has_next(&array_iter)) {
		if (is_interface_entry_bluez_device(&array_iter))
		    return object_path;
		dbus_message_iter_next(&array_iter);
	}

	return NULL;
}

static gboolean interfaces_added(DBusConnection *conn, DBusMessage *msg,
		void *user_data)
{
	const char *device_path = get_device_path_from_interface_msg(msg);

	if (!device_path)
		return TRUE;

	g_dbus_register_interface(btd_get_dbus_connection(),
					device_path, DBUS_PLUGIN_DEVICE_INTERFACE,
					device_methods, NULL, NULL, NULL, NULL);

	return TRUE;
}

static gboolean interfaces_removed(DBusConnection *conn, DBusMessage *msg,
		void *user_data)
{
	const char *device_path = get_device_path_from_interface_msg(msg);

	if (!device_path)
		return TRUE;

	g_dbus_unregister_interface(btd_get_dbus_connection(),
				device_path, DBUS_PLUGIN_DEVICE_INTERFACE);

	return TRUE;
}

static void remove_dbus_watches() {
	if (interfaces_added_watch_id)
		g_dbus_remove_watch(
			btd_get_dbus_connection(), interfaces_added_watch_id);

	if (interfaces_removed_watch_id)
		g_dbus_remove_watch(
			btd_get_dbus_connection(), interfaces_removed_watch_id);
}

static const GDBusPropertyTable chromium_properties[] = {
	{ "SupportsLEServices", "b",
				chromium_property_get_supports_le_services },
	{ "SupportsConnInfo", "b",
				chromium_property_get_supports_conn_info },
	{ }
};

static void read_version_complete(uint8_t status, uint16_t length,
					const void *param, void *user_data)
{
	const struct mgmt_rp_read_version *rp = param;
	uint8_t mgmt_version, mgmt_revision;

	if (status != MGMT_STATUS_SUCCESS) {
		error("Failed to read version information: %s (0x%02x)",
						mgmt_errstr(status), status);
		return;
	}

	if (length < sizeof(*rp)) {
		error("Wrong size of read version response");
		return;
	}

	mgmt_version = rp->version;
	mgmt_revision = btohs(rp->revision);

	supports_le_services = (mgmt_version > 1 ||
		(mgmt_version == 1 && mgmt_revision >= 4));
	supports_conn_info = (mgmt_revision > 1 ||
		(mgmt_version == 1 && mgmt_revision >= 5));

	g_dbus_emit_property_changed(btd_get_dbus_connection(),
		DBUS_PATH, DBUS_PLUGIN_INTERFACE, "SupportsLEServices");
	g_dbus_emit_property_changed(btd_get_dbus_connection(),
		DBUS_PATH, DBUS_PLUGIN_INTERFACE, "SupportsConnInfo");
}

static int chromium_init(void)
{
	DBG("");

	mgmt_if = mgmt_new_default();
	if (!mgmt_if)
		error("Failed to access management interface");
	else if (!mgmt_send(mgmt_if, MGMT_OP_READ_VERSION,
					MGMT_INDEX_NONE, 0, NULL,
					read_version_complete, NULL, NULL))
		error("Failed to read management version information");

	g_dbus_register_interface(btd_get_dbus_connection(),
		DBUS_PATH, DBUS_PLUGIN_INTERFACE,
		NULL, NULL, chromium_properties, NULL, NULL);

	/* Listen for new device objects being added so we can add the plugin
	 * interface to them.
	 */
	interfaces_added_watch_id = g_dbus_add_signal_watch(
			btd_get_dbus_connection(), DBUS_BLUEZ_SERVICE,
			"/", DBUS_OBJECT_MANAGER_INTERFACE, "InterfacesAdded",
			interfaces_added, NULL, NULL);
	if (!interfaces_added_watch_id) {
		error("Failed to add watch for InterfacesAdded signal");
		return 0;
	}

	interfaces_removed_watch_id = g_dbus_add_signal_watch(
			btd_get_dbus_connection(), DBUS_BLUEZ_SERVICE,
			"/", DBUS_OBJECT_MANAGER_INTERFACE, "InterfacesRemoved",
			interfaces_removed, NULL, NULL);
	if (!interfaces_removed_watch_id) {
		error("Failed to add watch for InterfaceRemoved signal");
		remove_dbus_watches();
	}

	return 0;
}

static void chromium_exit(void)
{
	DBG("");

	mgmt_unref(mgmt_if);
	mgmt_if = NULL;

	remove_dbus_watches();
}

BLUETOOTH_PLUGIN_DEFINE(chromium, VERSION, BLUETOOTH_PLUGIN_PRIORITY_HIGH,
						chromium_init, chromium_exit)
