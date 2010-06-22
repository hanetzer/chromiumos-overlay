# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

inherit eutils toolchain-funcs

DESCRIPTION="Chrome OS embedded bootstub"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE=""
EAPI="2"

DEPEND="sys-boot/gnu-efi"

SRCPATH=src/third_party/bootstub/files

src_unpack() {
	if [ -z "${CHROMEOS_ROOT}" ] ; then
		local CHROMEOS_ROOT=$(eval echo -n ~${SUDO_USER}/trunk)
	fi
	mkdir "${S}"
	cp -a "${CHROMEOS_ROOT}/${SRCPATH}"/* "${S}"/ || die
}


src_compile() {
	emake -j1 CC="$(tc-getCC)" LD="$(tc-getLD)" \
              OBJCOPY="$(tc-getPROG OBJCOPY objcopy)" \
              || die "${SRCPATH} compile failed."
}

src_install() {
	LIBDIR=$(get_libdir)
	emake DESTDIR="${D}/${LIBDIR}/bootstub" install || \
              die "${SRCPATH} install failed."
}
