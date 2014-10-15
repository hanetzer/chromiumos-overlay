# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/bsdiff/bsdiff-4.3-r2.ebuild,v 1.1 2010/12/13 00:35:03 flameeyes Exp $

EAPI=4

inherit eutils toolchain-funcs flag-o-matic

DESCRIPTION="bsdiff: Binary Differencer using a suffix alg"
HOMEPAGE="http://www.daemonology.net/bsdiff/"
SRC_URI="http://www.daemonology.net/bsdiff/${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="*"
IUSE="cros_host"

RDEPEND="app-arch/bzip2
	cros_host? ( dev-libs/libdivsufsort )"
DEPEND="${RDEPEND}
	dev-libs/libdivsufsort"

src_prepare() {
	epatch "${FILESDIR}"/${PV}_bspatch-extent-files.patch
	epatch "${FILESDIR}"/${PV}_bsdiff-divsufsort.patch
	epatch "${FILESDIR}"/${PV}_makefile.patch
	epatch "${FILESDIR}"/${PV}_sanity_check.patch
	epatch "${FILESDIR}"/${PV}_makefile_without_bsdiff.patch
}

src_configure() {
	append-lfs-flags
	tc-export CC
	makeargs=( USE_BSDIFF=y )
}

src_compile() {
	emake "${makeargs[@]}"
}

src_install() {
	emake install DESTDIR="${D}" "${makeargs[@]}"
}

pkg_preinst() {
	# We want bsdiff in the sdk and in the sysroot (for testing), but
	# we don't want it in the target image as it isn't used.
	if [[ $(cros_target) == "target_image" ]]; then
		rm "${D}"/usr/bin/bsdiff || die
	fi
}
