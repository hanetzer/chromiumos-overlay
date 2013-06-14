# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="5dfc8e1ae8c7d6836f2faef2545e4c5e6d516dff"
CROS_WORKON_TREE="96651aa91cffbc98f34c056fbb1911106c9faf93"
inherit eutils toolchain-funcs multiprocessing cros-workon

DESCRIPTION="GNU GRUB 2 boot loader"
HOMEPAGE="http://www.gnu.org/software/grub/"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="truetype"
CROS_WORKON_PROJECT="chromiumos/third_party/grub2"

RDEPEND=">=sys-libs/ncurses-5.2-r5
	dev-libs/lzo
	truetype? ( media-libs/freetype )"
DEPEND="${RDEPEND}
	dev-lang/ruby"
PROVIDE="virtual/bootloader"

export STRIP_MASK="*/*grub/*/*.mod"

CROS_WORKON_LOCALNAME="grub2"

src_configure() {
	local target
	multijob_init
	for target in i386 x86_64 ; do
		local program_prefix=
		[[ ${target} != "x86_64" ]] && program_prefix=${target}-
		mkdir -p ${target}-build
		pushd ${target}-build >/dev/null
		ECONF_SOURCE="${S}" multijob_child_init econf \
			--disable-werror \
			--disable-grub-mkfont \
			--disable-grub-fstest \
			--disable-efiemu \
			--sbindir=/sbin \
			--bindir=/bin \
			--libdir=/$(get_libdir) \
			--with-platform=efi \
			--target=${target} \
			--program-prefix=${program_prefix}
		popd >/dev/null
	done
	multijob_finish
}

src_compile() {
	multijob_init
	multijob_child_init emake -C i386-build -j1 \
		COMMON_LDFLAGS='-Wl,-melf_i386 -nostdlib'
	multijob_child_init emake -C x86_64-build -j1
	multijob_finish
}

src_install() {
	multijob_init
	multijob_child_init emake -C i386-build DESTDIR="${D}" install
	multijob_child_init emake -C x86_64-build DESTDIR="${D}" install
	multijob_finish
}
