# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

inherit eutils toolchain-funcs

DESCRIPTION="GNU GRUB 2 boot loader"
HOMEPAGE="http://www.gnu.org/software/grub/"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE=""
EAPI="2"

RDEPEND=">=sys-libs/ncurses-5.2-r5
	dev-libs/lzo
	truetype? ( media-libs/freetype )"
DEPEND="${RDEPEND}
	dev-lang/ruby"
PROVIDE="virtual/bootloader"

export STRIP_MASK="*/grub/*/*.mod"


SRCPATH=src/third_party/grub2

src_unpack() {
	if [ -z "${CHROMEOS_ROOT}" ] ; then
		local CHROMEOS_ROOT=$(eval echo -n ~${SUDO_USER}/trunk)
	fi
	cp -a "${CHROMEOS_ROOT}/${SRCPATH}" "${S}" || die
}

src_configure() {
	econf \
		--disable-werror \
		--disable-grub-mkfont \
		--disable-grub-fstest \
		--disable-efiemu \
		--sbindir=/sbin \
		--bindir=/bin \
		--libdir=/$(get_libdir) \
		--with-platform=efi \
		--target=x86_64 \
		--program-prefix=
}

src_compile() {
	emake -j1 || die "${SRCPATH} compile failed."
}

src_install() {
	emake DESTDIR="${D}" install || die
}
