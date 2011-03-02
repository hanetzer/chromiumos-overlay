# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs cros-debug cros-workon

DESCRIPTION="Chrome OS base library."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm"
IUSE="test"

# TODO: Ideally this is only a build depend, but there is an ordering
# issue where we need to make sure that libchrome is built first.
RDEPEND="chromeos-base/libchrome
	dev-libs/dbus-glib
	dev-libs/libpcre"

DEPEND="${RDEPEND}
	test? ( dev-cpp/gtest )"

CROS_WORKON_PROJECT="common"
CROS_WORKON_LOCALNAME="../common" # FIXME: HACK

src_compile() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG
	export CCFLAGS="$CFLAGS"
	scons || die "third_party/chrome compile failed."
}

src_test() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG
	export CCFLAGS="$CFLAGS"
	scons || die
	if ! use x86; then
	        echo Skipping unit tests on non-x86 platform
	else
	        ./unittests || die "unittests failed"
	fi
}

src_install() {
	dodir "/usr/lib"
	dodir "/usr/include/chromeos"
	dodir "/usr/include/chromeos/dbus"
	dodir "/usr/include/chromeos/glib"

	insopts -m0644
	insinto "/usr/lib"
	doins "${S}/libchromeos.a"

	insinto "/usr/include/chromeos"
	doins "${S}/chromeos/callback.h"
	doins "${S}/chromeos/exception.h"
	doins "${S}/chromeos/process.h"
	doins "${S}/chromeos/process_mock.h"
	doins "${S}/chromeos/string.h"
	doins "${S}/chromeos/syslog_logging.h"
	doins "${S}/chromeos/test_helpers.h"
	doins "${S}/chromeos/utility.h"

	insinto "/usr/include/chromeos/dbus"
	doins "${S}/chromeos/dbus/abstract_dbus_service.h"
	doins "${S}/chromeos/dbus/dbus.h"
	doins "${S}/chromeos/dbus/service_constants.h"

	insinto "/usr/include/chromeos/glib"
	doins "${S}/chromeos/glib/object.h"
}
