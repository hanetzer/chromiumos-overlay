# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="Custom e2fsprogs using LAZY_BG for lazy resizing"
HOMEPAGE="http://e2fsprogs.sourceforge.net/"
SRC_URI=""
LICENSE="GPL-2 BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

RDEPEND="nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )
	dev-util/pkgconfig
	sys-apps/texinfo"


src_unpack() {
	if [ -n "$CHROMEOS_ROOT" ] ; then
		local third_party="${CHROMEOS_ROOT}/src/third_party"
		local e4fsprogs="${third_party}/e2fsprogs/files"
		elog "Using e2fsprogs dir: $e4fsprogs"
		mkdir -p "${S}"
		cp -a "${e4fsprogs}"/* "${S}" || die
	else
		unpack ${A}
	fi
}

src_compile() {
	if tc-is-cross-compiler ; then
		tc-getCC
		tc-getCXX
		tc-getAR
		tc-getRANLIB
		tc-getLD
		tc-getNM
		export PKG_CONFIG_PATH="${ROOT}/usr/lib/pkgconfig/"
		export CCFLAGS="$CFLAGS"
	fi

	econf || die "$PN configure failed."
	emake libs && emake progs || die "$PN compile failed."
}

src_install() {
	into "/usr/lib/${PN}/"
	dobin "${S}/misc/e4defrag"
	dobin "${S}/resize/resize2fs"
	dobin "${S}/e2fsck/e2fsck"
	newbin "${S}/misc/mke2fs" mkfs.ext4
}
