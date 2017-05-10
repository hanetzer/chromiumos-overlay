# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="0dfff398fc9df72af2ebdd205b5722e397e575b4"
CROS_WORKON_TREE="3f5cce4862a61c3fc641258645c1fb20d928a33d"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_PROJECT="chromiumos/platform/vboot_reference"

inherit cros-debug cros-workon cros-au

DESCRIPTION="Chrome OS verified boot tools"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="32bit_au cros_host dev_debug_force -mtd pd_sync tpmtests tpm tpm2"

REQUIRED_USE="tpm2? ( !tpm )"

RDEPEND="cros_host? ( dev-libs/libyaml )
	mtd? ( sys-apps/flashrom )
	dev-libs/openssl
	sys-apps/util-linux"
DEPEND="mtd? ( dev-embedded/android_mtdutils )
	${RDEPEND}"

src_configure() {
	cros-workon_src_configure
}

vemake() {
	emake \
		SRCDIR="${S}" \
		LIBDIR="$(get_libdir)" \
		ARCH=$(tc-arch) \
		TPM2_MODE=$(usev tpm2) \
		PD_SYNC=$(usev pd_sync) \
		USE_MTD=$(usev mtd) \
		MINIMAL=$(usev !cros_host) \
		DEV_DEBUG_FORCE=$(usev dev_debug_force) \
		"$@"
}

_src_compile_main() {
	mkdir "${WORKDIR}"/build-main
	tc-export CC AR CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	# Vboot reference knows the flags to use
	unset CFLAGS
	vemake BUILD="${WORKDIR}"/build-main all
	unset CC AR CXX PKG_CONFIG
}

_src_compile_au() {
	board_setup_32bit_au_env
	mkdir "${WORKDIR}"/build-au
	einfo "Building 32-bit library for installer to use"
	tc-export CC AR CXX PKG_CONFIG
	vemake BUILD="${WORKDIR}"/build-au/ tinyhostlib
	unset CC AR CXX PKG_CONFIG
	board_teardown_32bit_au_env
}

src_compile() {
	_src_compile_main
	use 32bit_au && _src_compile_au
}

src_test() {
	! use amd64 && ! use x86 && ewarn "Skipping unittests for non-x86" && return 0
	vemake BUILD="${WORKDIR}"/build-main runtests
}

src_install() {
	einfo "Installing programs"
	vemake \
		BUILD="${WORKDIR}"/build-main \
		DESTDIR="${D}$(usex cros_host /usr '')" \
		install$(usex mtd '_mtd' '')

	if use cros_host; then
		# Installing on the host
		exeinto /usr/share/vboot/bin
		doexe scripts/image_signing/*.sh
	fi

	if use tpmtests; then
		into /usr
		# copy files starting with tpmtest, but skip .d files.
		dobin "${WORKDIR}"/build-main/tests/tpm_lite/tpmtest*[^.]?
		dobin "${WORKDIR}"/build-main/utility/tpm_set_readsrkpub
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
	      firmware/include/tss_constants.h \
	      firmware/include/tpm1_tss_constants.h \
	      firmware/include/tpm2_tss_constants.h

	einfo "Installing host library"
	dolib.a "${WORKDIR}"/build-main/libvboot_host.a

	# Install 32-bit library needed by installer programs.
	if use 32bit_au; then
		einfo "Installing 32-bit host library"
		insopts -m0644
		insinto /usr/lib/vboot32
		doins "${WORKDIR}"/build-au/libvboot_host.a
	fi
}
