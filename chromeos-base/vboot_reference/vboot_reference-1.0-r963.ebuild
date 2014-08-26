# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="f510973497a430c1bb41d9b7e996d02fb7f7179e"
CROS_WORKON_TREE="ec38ec802e2924d38d2893268c69f3f2b9cca712"
CROS_WORKON_PROJECT="chromiumos/platform/vboot_reference"

inherit cros-debug cros-workon cros-au

DESCRIPTION="Chrome OS verified boot tools"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="32bit_au minimal tpmtests cros_host vboot2 pd_sync"

RDEPEND="!minimal? ( dev-libs/libyaml )
	dev-libs/openssl
	sys-apps/util-linux"
DEPEND="app-crypt/trousers
	${RDEPEND}"

src_configure() {
	cros-workon_src_configure
}

_src_compile_main() {
	mkdir "${S}"/build-main
	tc-export CC AR CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	# Vboot reference knows the flags to use
	unset CFLAGS
	emake BUILD="${S}"/build-main \
	      ARCH=$(tc-arch) \
	      VBOOT2=$(usev vboot2) \
	      PD_SYNC=$(usev pd_sync) \
	      MINIMAL=$(usev minimal) all
	unset CC AR CXX PKG_CONFIG
}

_src_compile_au() {
	board_setup_32bit_au_env
	mkdir "${S}"/build-au
	einfo "Building 32-bit library for installer to use"
	tc-export CC AR CXX PKG_CONFIG
	emake BUILD="${S}"/build-au/ \
	      ARCH=$(tc-arch) \
	      VBOOT2=$(usev vboot2) \
	      PD_SYNC=$(usev pd_sync) \
	      MINIMAL=$(usev minimal) tinyhostlib
	unset CC AR CXX PKG_CONFIG
	board_teardown_32bit_au_env
}

src_compile() {
	_src_compile_main
	use 32bit_au && _src_compile_au
}

src_test() {
	! use amd64 && ! use x86 && ewarn "Skipping unittests for non-x86" && return 0
	emake BUILD="${S}"/build-main \
	      ARCH=$(tc-arch) \
	      VBOOT2=$(usev vboot2) \
	      PD_SYNC=$(usev pd_sync) \
	      MINIMAL=$(usev minimal) runtests
}

src_install() {
	einfo "Installing programs"
	if use minimal ; then
		# Installing on the target
		emake BUILD="${S}"/build-main DESTDIR="${D}" \
		      VBOOT2=$(usev vboot2) \
		      PD_SYNC=$(usev pd_sync) \
		      MINIMAL=1 install
	else
		# Installing on the host
		emake BUILD="${S}"/build-main DESTDIR="${D}/usr/bin" \
		      VBOOT2=$(usev vboot2) \
		      PD_SYNC=$(usev pd_sync) \
		      install
	fi

	if use tpmtests; then
		into /usr
		# copy files starting with tpmtest, but skip .d files.
		dobin "${S}"/build-main/tests/tpm_lite/tpmtest*[^.]?
		dobin "${S}"/build-main/utility/tpm_set_readsrkpub
	fi

	# Install devkeys to /usr/share/vboot/devkeys
	# (shared by host and target)
	einfo "Installing devkeys"
	insinto /usr/share/vboot/devkeys
	doins tests/devkeys/*

	# Install public headers to /build/${BOARD}/usr/include/vboot
	einfo "Installing header files"
	insinto /usr/include/vboot
	doins host/include/* \
	      firmware/include/gpt.h \
	      firmware/include/tlcl.h \
	      firmware/include/tss_constants.h

	einfo "Installing host library"
	dolib.a build-main/libvboot_host.a

	# Install 32-bit library needed by installer programs.
	if use 32bit_au; then
		einfo "Installing 32-bit host library"
                insopts -m0644
                insinto /usr/lib/vboot32
                doins build-au/libvboot_host.a
	fi
}
