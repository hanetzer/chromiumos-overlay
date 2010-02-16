# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="Encrypted home directories for Chromium OS"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE="test"

RDEPEND="
	sys-auth/pam_mount
	sys-fs/lvm2
	sys-fs/e4fsprogs
	dev-libs/dbus-glib
	dev-libs/glib
	dev-libs/openssl
	app-shells/bash
	sys-libs/pam"

DEPEND="
	test? ( dev-cpp/gtest )
	chromeos-base/libchromeos
	${RDEPEND}"

src_unpack() {
	local platform="${CHROMEOS_ROOT}/src/platform"
	elog "Using platform: $platform"
	mkdir -p "${S}/cryptohome"
	cp -a "${platform}/cryptohome" "${S}" || die
}

src_compile() {
	if tc-is-cross-compiler ; then
		tc-getCC
		tc-getCXX
		tc-getAR
		tc-getRANLIB
		tc-getLD
		tc-getNM
		export CCFLAGS="$CFLAGS"
	fi

	pushd cryptohome
	# Only build the daemon
	scons cryptohomed || die "cryptohome compile failed."
	popd
}

src_test() {
	if tc-is-cross-compiler ; then
		tc-getCC
		tc-getCXX
		tc-getAR
		tc-getRANLIB
		tc-getLD
		tc-getNM
		export CCFLAGS="$CFLAGS"
	fi

	pushd cryptohome
	# Only build the tests
	# TODO(wad) eclass-ify this.
	scons cryptohome_testrunner ||
		die "cryptohome_testrunner compile failed."
	popd
}

src_install() {
	S="${S}/cryptohome"
	newsbin "${S}/bin/mount" mount.cryptohome
	newsbin "${S}/bin/umount" umount.cryptohome

	dosbin "${S}/cryptohomed"
	dolib "${S}/libcryptohome_service.so"

	dodir /etc/dbus-1/system.d
	cp "${S}/etc/Cryptohome.conf" \
		"${D}/etc/dbus-1/system.d/Cryptohome.conf"

	dodir /usr/share/dbus-1/services/
	cp "${S}/share/org.chromium.Cryptohome.service" \
		"${D}/usr/share/dbus-1/services/"

	dodir /usr/lib/chromeos-cryptohome
	cp -a "${S}"/lib/* "${D}/usr/lib/chromeos-cryptohome"
}
