# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="Enterprise policy management daemon."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

RDEPEND="chromeos-base/libcros
	 dev-lang/v8
	 dev-libs/dbus-glib
	 dev-libs/libevent
	 dev-libs/opencryptoki
	 net-misc/curl"

DEPEND="chromeos-base/libchrome
	chromeos-base/libchromeos
	${RDEPEND}"

src_unpack() {
	local platform="${CHROMEOS_ROOT}/src/platform"
	elog "Using platform: $platform"
	mkdir -p "${S}/entd"
	cp -a "${platform}/entd" "${S}" || die
}

src_compile() {
	tc-export CC CXX PKG_CONFIG
	export BUILD_DIR=out
	pushd entd
	scons SYSROOT=$SYSROOT || die "end compile failed."
	popd
}

src_install() {
	dosbin "${S}/entd/${BUILD_DIR}/entd"

	ENTD_CONF_DIR="/etc/entd"
	dodir "${ENTD_CONF_DIR}"
	insinto "${ENTD_CONF_DIR}"
	doins "${S}"/entd/base_policy/*
}
