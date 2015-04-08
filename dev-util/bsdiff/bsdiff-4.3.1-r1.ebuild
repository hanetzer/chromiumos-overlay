# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/bsdiff/bsdiff-4.3-r2.ebuild,v 1.1 2010/12/13 00:35:03 flameeyes Exp $

EAPI=4
CROS_WORKON_COMMIT="be22c479293df0c89ff71bb53dfd01ad0fe73b0c"
CROS_WORKON_TREE="5bd90f75dff64699a99c40e80374127f8f73158a"
CROS_WORKON_PROJECT="chromiumos/third_party/bsdiff"

inherit cros-workon toolchain-funcs flag-o-matic

DESCRIPTION="bsdiff: Binary Differencer using a suffix alg"
HOMEPAGE="http://www.daemonology.net/bsdiff/"
SRC_URI=""

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="*"
IUSE="cros_host"

RDEPEND="app-arch/bzip2
	cros_host? ( dev-libs/libdivsufsort )"
DEPEND="${RDEPEND}
	dev-libs/libdivsufsort"

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
