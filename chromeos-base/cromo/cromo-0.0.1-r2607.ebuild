# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="5dbceea5e91932e855404807d551d73894580735"
CROS_WORKON_TREE=("0295472676671915bab943e84d561ed834ea7622" "1b5fdc55318e7169f14b67d1fd7edb8fd982f9b8" "f151afc2e5241eeb2ae52d3c83d124e1f0dcc836")
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_USE_VCSID="1"
CROS_WORKON_OUTOFTREE_BUILD=1
# TODO(crbug.com/809389): Avoid directly including headers from other packages.
CROS_WORKON_SUBTREE="common-mk cromo metrics"

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
	chromeos-base/minijail
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