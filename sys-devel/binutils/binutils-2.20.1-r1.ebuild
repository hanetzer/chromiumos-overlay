# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"

PATCHVER=""
ELF2FLT_VER=""
UCLIBC_PATCHVER=""

inherit toolchain-binutils

COST_VERSION="v1"
COST_CL="43408"
COST_SUFFIX="cos_gg_${COST_VERSION}_${COST_CL}"
COST_PKG_VERSION="binutils-2.20.1.20100303_${COST_SUFFIX}"

BINUTILS_TYPE="crosstool"
BVER=${PV}
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/binutils-2.20.1.20100303_cos_gg_v1_43408.tar.gz"
EXTRA_ECONF="${EXTRA_ECONF} --disable-checking --enable-gold=both/ld \
--with-bugurl=http://code.google.com/p/chromium-os/issues/entry \
--with-pkgversion=${COST_PKG_VERSION}"

src_unpack() {
	# The eclass unpacks source AND applies patches, we don't want patches
	tc-binutils_unpack
}

src_install() {
	toolchain-binutils_src_install

	# Install linkers into subdirectories so they can be selected with gcc -B
	mkdir "${D}"/${BINPATH}/ld-bfd
	mkdir "${D}"/${BINPATH}/ld-gold
	ln -s "${D}"/${BINPATH}/ld.bfd "${D}"/${BINPATH}/ld-bfd/ld
	ln -s "${D}"/${BINPATH}/ld.gold "${D}"/${BINPATH}/ld-gold/ld
}

