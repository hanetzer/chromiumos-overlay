# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="5531127b63b40e4f9ead1b60f9f60fe501ad45d4"
CROS_WORKON_TREE="3abdc949c06e48c09409d6686de78f35d2580d89"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_USE_VCSID="1"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="cromo"

inherit cros-workon platform user

DESCRIPTION="Chromium OS modem manager"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	chromeos-base/chromeos-minijail
	chromeos-base/libbrillo
	chromeos-base/metrics
	>=dev-libs/glib-2.0
	dev-libs/dbus-c++
	virtual/modemmanager
"

DEPEND="${RDEPEND}
	chromeos-base/system_api
	"

src_install() {
	dosbin "${OUT}"/cromo
	dolib.so "${OUT}"/libcromo.a

	insinto /etc/dbus-1/system.d
	doins org.chromium.ModemManager.conf

	insinto /usr/include/cromo
	doins modem_handler.h cromo_server.h plugin.h \
		hooktable.h carrier.h utilities.h modem.h \
		sms_message.h sms_cache.h

	insinto /usr/include/cromo/dbus_adaptors
	doins "${OUT}"/gen/include/dbus_adaptors/mm-{mobile,serial}-error.h
	doins "${OUT}"/gen/include/dbus_adaptors/org.freedesktop.ModemManager.*.h
	doins "${OUT}"/gen/include/cromo/dbus_adaptors/org.freedesktop.DBus.Properties.h

	insinto /etc/init
	doins init/cromo.conf
}

pkg_preinst() {
	local ug
	for ug in cromo qdlservice; do
		enewuser "${ug}"
		enewgroup "${ug}"
	done
}

platform_pkg_test() {
	local tests=(
		sms_message_unittest
		sms_cache_unittest
		utilities_unittest
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}
