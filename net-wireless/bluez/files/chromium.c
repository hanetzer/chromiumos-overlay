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
#include "src/dbus-common.h"
#include "src/log.h"
#include "src/plugin.h"
#include "src/shared/mgmt.h"

#define DBUS_PATH "/org/bluez"
#define DBUS_INTERFACE "org.chromium.Bluetooth"

static struct mgmt *mgmt_if = NULL;

static bool supports_le_services = false;

static gboolean chromium_property_get_supports_le_services(
					const GDBusPropertyTable *property,
					DBusMessageIter *iter, void *data)
{
	dbus_bool_t value = supports_le_services;

	dbus_message_iter_append_basic(iter, DBUS_TYPE_BOOLEAN, &value);

	return TRUE;
}

static const GDBusPropertyTable chromium_properties[] = {
	{ "SupportsLEServices", "b",
				chromium_property_get_supports_le_services },
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

	g_dbus_emit_property_changed(btd_get_dbus_connection(),
		DBUS_PATH, DBUS_INTERFACE, "SupportsLEServices");
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
		DBUS_PATH, DBUS_INTERFACE,
		NULL, NULL, chromium_properties, NULL, NULL);

	return 0;
}

static void chromium_exit(void)
{
	DBG("");

	mgmt_unref(mgmt_if);
	mgmt_if = NULL;
}

BLUETOOTH_PLUGIN_DEFINE(chromium, VERSION, BLUETOOTH_PLUGIN_PRIORITY_HIGH,
						chromium_init, chromium_exit)
