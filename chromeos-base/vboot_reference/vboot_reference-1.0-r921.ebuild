# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="850b74fa19f6eadd1d3221f484c738f41f993653"
CROS_WORKON_TREE="37351c34a77079000d5daa458779f1dfbff577c2"
CROS_WORKON_PROJECT="chromiumos/platform/vboot_reference"

inherit cros-debug cros-workon cros-au

DESCRIPTION="Chrome OS verified boot tools"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="32bit_au minimal tpmtests cros_host"

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
	      MINIMAL=$(usev minimal) tinyhostlib
	unset CC AR CXX PKG_CONFIG
	board_teardown_32bit_au_env
}

src_compile() {
	_src_compile_main
	use 32bit_au && _src_compile_au
}

src_test() {
	emake BUILD="${S}"/build-main \
	      ARCH=$(tc-arch) \
	      MINIMAL=$(usev minimal) runtests
}

src_install() {
	einfo "Installing programs"
	if use minimal ; then
		# Installing on the target
		emake BUILD="${S}"/build-main DESTDIR="${D}" MINIMAL=1 install
	else
		# Installing on the host
		emake BUILD="${S}"/build-main DESTDIR="${D}/usr/bin" install
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
	doins firmware/include/* host/include/*

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
