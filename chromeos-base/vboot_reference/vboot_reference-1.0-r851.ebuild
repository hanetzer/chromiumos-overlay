# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="77f55ca1cd282ac6c540ea3a8bacbc35c2600d60"
CROS_WORKON_TREE="fe5a9950810e484603b95ecbf7dff6fe743e037d"
CROS_WORKON_PROJECT="chromiumos/platform/vboot_reference"

inherit cros-debug cros-workon cros-au

DESCRIPTION="Chrome OS verified boot tools"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="32bit_au minimal tpmtests cros_host"

RDEPEND="!minimal? ( dev-libs/libyaml )
	dev-libs/openssl
	sys-apps/util-linux"
DEPEND="app-crypt/trousers
	${RDEPEND}"

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
	local dst_dir
	einfo "Installing programs"
	if use minimal ; then
		# Installing on the target
		emake BUILD="${S}"/build-main DESTDIR="${D}" MINIMAL=1 install

		# TODO(hungte) Since we now install all keyset into
		# /usr/share/vboot/devkeys, maybe SAFT does not need to install
		# its own keys anymore.
		einfo "Installing keys for SAFT"
		local keys_to_install='recovery_kernel_data_key.vbprivk'
		keys_to_install+=' firmware.keyblock '
		keys_to_install+=' firmware_data_key.vbprivk'
		keys_to_install+=' kernel_subkey.vbpubk'
		keys_to_install+=' kernel_data_key.vbprivk'

		dst_dir='/usr/sbin/firmware/saft'
		dodir "${dst_dir}"
		insinto "${dst_dir}"
		for key in ${keys_to_install}; do
			doins "tests/devkeys/${key}"
		done
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
	dst_dir='/usr/share/vboot/devkeys'
	dodir "${dst_dir}"
	insinto "${dst_dir}"
	doins tests/devkeys/*

	einfo "Installing header files and libraries"

	# Install firmware/include to /build/${BOARD}/usr/include/vboot
	local dst_dir='/usr/include/vboot'
	dodir "${dst_dir}"
	insinto "${dst_dir}"
	doins -r firmware/include/* host/include/*

        # FIXME(crosbug.com/39444): Don't violate the implied API. These
        # headers should be relocated in the source if they're really
        # needed.
	insinto /usr/include/vboot/
	doins "cgpt/cgpt.h"
	doins "cgpt/cgpt_params.h"
	doins "utility/include/kernel_blob.h"
	doins "utility/include/dump_kernel_config.h"
	doins "firmware/lib/cgptlib/include/cgptlib.h"
	doins "firmware/lib/cgptlib/include/gpt.h"

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
