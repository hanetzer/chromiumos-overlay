# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="df6034c59cb2d847f9e780cf2def30c5c9b8305f"
CROS_WORKON_TREE="a36ac8b6b01b250b05a29d6eb9c994c78c1153de"
inherit eutils toolchain-funcs multiprocessing cros-workon

DESCRIPTION="GNU GRUB 2 boot loader"
HOMEPAGE="http://www.gnu.org/software/grub/"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE=""
CROS_WORKON_PROJECT="chromiumos/third_party/grub2"

PROVIDE="virtual/bootloader"

export STRIP_MASK="*.img *.mod *.module"

CROS_WORKON_LOCALNAME="grub2"

src_configure() {
	local target
	# Fix timestamps to prevent unnecessary rebuilding
	find "${S}" -exec touch -r "${S}/configure" {} +
	multijob_init
	for target in i386 x86_64 ; do
		mkdir -p ${target}-build
		pushd ${target}-build >/dev/null
                # GRUB defaults to a --program-prefix set based on target
                # platform; explicitly set it to nothing to install unprefixed
                # tools.  https://savannah.gnu.org/bugs/?39818
		ECONF_SOURCE="${S}" multijob_child_init econf \
			--disable-werror \
			--disable-grub-mkfont \
			--disable-grub-mount \
			--disable-device-mapper \
			--disable-efiemu \
			--disable-libzfs \
			--disable-nls \
			--sbindir=/sbin \
			--bindir=/bin \
			--libdir=/$(get_libdir) \
			--with-platform=efi \
			--target=${target} \
			--program-prefix=
		popd >/dev/null
	done
	multijob_finish
}

src_compile() {
	multijob_init
	multijob_child_init emake -C i386-build -j1
	multijob_child_init emake -C x86_64-build -j1
	multijob_finish
}

src_install() {
	# The two installations have several file conflicts that prevent
	# parallel installation.
	emake -C i386-build DESTDIR="${D}" install
	emake -C x86_64-build DESTDIR="${D}" install
}
