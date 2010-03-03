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

	if use x86 ; then
		# Create data for unittests
		./init_cryptohome_data.sh test_image_dir

		LIBC_PATH="${SYSROOT}/usr/lib/gcc/${CHOST}/"$(gcc-fullversion)
		LIB_PATHS=".:${SYSROOT}/usr/lib:${SYSROOT}/lib"
		# Set the library paths appropriately and
        	# run the unit tests with the right loader.
        	LD_LIBRARY_PATH=$LIB_PATHS:${LIBC_PATH} \
			${SYSROOT}/lib/ld-linux.so.2 ./cryptohome_testrunner \
			${GTEST_ARGS} || die "unit tests failed!"
	fi
	popd
}

src_install() {
	S="${S}/cryptohome"
	newsbin "${S}/bin/mount" mount.cryptohome
	newsbin "${S}/bin/umount" umount.cryptohome

	dosbin "${S}/cryptohomed"
	dolib "${S}/libcryptohome_service.so"

	dodir /etc/dbus-1/system.d
	insinto /etc/dbus-1/system.d
	doins "${S}/etc/Cryptohome.conf"

	dodir /usr/share/dbus-1/services/
	insinto /usr/share/dbus-1/services/
	doins "${S}/share/org.chromium.Cryptohome.service"

	dodir /usr/lib/chromeos-cryptohome
	insinto /usr/lib/chromeos-cryptohome
	doins "${S}"/lib/*
}
