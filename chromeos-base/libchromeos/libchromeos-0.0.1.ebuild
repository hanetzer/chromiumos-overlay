# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="Chrome OS base library."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

DEPEND="dev-libs/dbus-glib"

# TODO: Ideally this is only a build depend, but there is an ordering
# issue where we need to make sure that libchrome is built first.
RDEPEND="chromeos-base/libchrome
	dev-libs/dbus-glib
	dev-libs/libpcre"

src_unpack() {
	local common="${CHROMEOS_ROOT}/src/common/"
	elog "Using common: $common"
	mkdir -p "${S}"
	cp -a "${common}"/* "${S}" || die
}

src_compile() {
	if tc-is-cross-compiler ; then
		tc-getCC
		tc-getCXX
		tc-getAR
		tc-getRANLIB
		tc-getLD
		tc-getNM
		export PKG_CONFIG_PATH="${ROOT}/usr/lib/pkgconfig/"
		export CCFLAGS="$CFLAGS"
	fi

	scons || die "third_party/chrome compile failed."
}

src_install() {
	mkdir -p "${D}/usr/lib" \
		"${D}/usr/include/chromeos" \
		"${D}/usr/include/chromeos/dbus" \
		"${D}/usr/include/chromeos/glib"

	cp "${S}/libchromeos.a" "${D}/usr/lib"

	cp "${S}/chromeos/callback.h" \
		"${S}/chromeos/exception.h" \
		"${S}/chromeos/obsolete_logging.h" \
		"${S}/chromeos/string.h" \
		"${S}/chromeos/utility.h" \
		"${D}/usr/include/chromeos"

	cp "${S}/chromeos/dbus/abstract_dbus_service.h" \
		"${S}/chromeos/dbus/dbus.h" \
		"${S}/chromeos/dbus/service_constants.h" \
		"${D}/usr/include/chromeos/dbus"

	cp "${S}/chromeos/glib/object.h" "${D}/usr/include/chromeos/glib"
}
