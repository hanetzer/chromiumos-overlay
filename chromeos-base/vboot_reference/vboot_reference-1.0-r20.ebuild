# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

inherit cros-workon

DESCRIPTION="Chrome OS verified boot tools"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="minimal rbtest"
EAPI="2"
CROS_WORKON_COMMIT="9b16a66b9befba01cb3379656d62c4168bfc001c"

DEPEND="app-crypt/trousers
	dev-libs/openssl
        sys-apps/util-linux"

src_compile() {
	tc-export CC AR CXX
	err_msg="${PN} compile failed. "
	err_msg+="Try running 'make clean' in the package root directory"
	emake || die "${err_msg}"
        if use rbtest; then
                emake rbtest || die "${err_msg}"
        fi
}

src_install() {
	if use minimal ; then
		emake DESTDIR="${D}/usr/bin" BUILD="${S}"/build -C cgpt \
		      install || die "${PN} install failed."
		# utility/ is all or nothing, just pick out what we want.
		into "/usr"
		dobin "${S}"/build/utility/dump_kernel_config
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
}
