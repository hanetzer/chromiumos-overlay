# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

inherit cros-workon

DESCRIPTION="Chrome OS verified boot tools"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="minimal rbtest tpmtests"
EAPI="2"
CROS_WORKON_COMMIT="2f6a71fb34c03c4ce04d46b2ec3a91b612d7bc3e"

DEPEND="app-crypt/trousers
	dev-libs/openssl
        sys-apps/util-linux"

src_compile() {
	tc-export CC AR CXX
	local err_msg="${PN} compile failed. "
	err_msg+="Try running 'make clean' in the package root directory"
	emake || die "${err_msg}"
        if use rbtest; then
                emake rbtest || die "${err_msg}"
        fi
}

src_install() {
	if use minimal ; then
		# Installing on the target. Cherry pick programs generated
		# by src_compile in the source tree build/ subdirectory
		local progs='utility/dump_kernel_config'
		progs+=' utility/dev_sign_file'
		progs+=' utility/tpm_init_temp_fix'
		progs+=' utility/tpmc'
		progs+=' utility/vbutil_key'
		progs+=' utility/vbutil_kernel'
		progs+=' utility/vbutil_firmware'
		progs+=' utility/gbb_utility'
		progs+=' utility/dump_fmap'
		progs+=' utility/dev_debug_vboot'
		progs+=' cgpt/cgpt'

		into "/usr"
		for prog in ${progs}; do
			dobin "${S}"/build/"${prog}"
		done

		local keys_to_install='recovery_kernel_data_key.vbprivk'
		keys_to_install+=' firmware.keyblock '
		keys_to_install+=' firmware_data_key.vbprivk'
		keys_to_install+=' kernel_subkey.vbpubk'

		dst_dir='/usr/sbin/firmware/saft'
		dodir "${dst_dir}"
		insinto "${dst_dir}"
		for key in ${keys_to_install}; do
		    doins "tests/devkeys/${key}"
		done
	else
		emake DESTDIR="${D}/usr/bin" install || \
			die "${PN} install failed."
		dodir /usr/share/vboot/devkeys
		insinto /usr/share/vboot/devkeys
		doins tests/devkeys/*
	fi
        if use rbtest; then
                emake DESTDIR="${D}/usr/bin" BUILD="${S}"/build -C tests \
                      install-rbtest || die "${PN} install failed."
        fi
        if use tpmtests; then
                into "/usr"
                # copy files starting with tpmtest, but skip .d files.
                dobin ${S}/build/tests/tpm_lite/tpmtest*[^.]?
                dobin ${S}/build/utility/tpm_set_readsrkpub
        fi

	# Install firmware/include to /build/${BOARD}/usr/include/vboot
	dodir /usr/include/vboot
	insinto /usr/include/vboot
	doins -r firmware/include/*

	# Install vboot_fw.a to /build/${BOARD}/usr/lib
	insinto /usr
	dolib.a "${S}"/build/vboot_fw.a
}
