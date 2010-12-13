# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="e01ca1408afc6da117cf6cc2af01e9dbdd723420"

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="Enterprise policy management daemon."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

RDEPEND="chromeos-base/libcros
	 dev-lang/v8
	 dev-libs/dbus-glib
	 dev-libs/libevent
	 dev-libs/opencryptoki
	 net-misc/curl"

DEPEND="chromeos-base/libchrome
	chromeos-base/libchromeos
	chromeos-base/libcros
	${RDEPEND}"

src_compile() {
	tc-export CC CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	export BUILD_DIR=out CCFLAGS="$CFLAGS"
	scons SYSROOT=$SYSROOT || die "end compile failed."
}

src_install() {
	dosbin "${BUILD_DIR}/entd"

	ENTD_CONF_DIR="/etc/entd"
	dodir "${ENTD_CONF_DIR}"
	insinto "${ENTD_CONF_DIR}"
	doins base_policy/*

	insinto /etc
	doins nsswitch.conf

	# Symlink the "Chrome Enterprise" browser policy locations into the
	# stateful partition.
	dodir /etc/chromium/
	dosym $SHARED_USER_HOME/var/browser-policies /etc/chromium/policies
	dodir /etc/opt/chrome/
	dosym $SHARED_USER_HOME/var/browser-policies /etc/opt/chrome/policies

	dosbin bin/fix_pkcs11_token.sh
	dosbin bin/entdwife.sh
}
