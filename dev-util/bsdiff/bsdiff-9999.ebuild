# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/bsdiff/bsdiff-4.3-r2.ebuild,v 1.1 2010/12/13 00:35:03 flameeyes Exp $

EAPI=4
CROS_WORKON_BLACKLIST=1
# cros-workon expects the repo to be in src/third_party, but is in src/aosp.
CROS_WORKON_LOCALNAME="../aosp/external/bsdiff"
CROS_WORKON_PROJECT="platform/external/bsdiff"
CROS_WORKON_REPO="https://android.googlesource.com"
CROS_WORKON_INCREMENTAL_BUILD=1

inherit cros-workon toolchain-funcs flag-o-matic

DESCRIPTION="bsdiff: Binary Differencer using a suffix alg"
HOMEPAGE="http://www.daemonology.net/bsdiff/"
SRC_URI=""

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~*"
IUSE="cros_host test"

RDEPEND="app-arch/bzip2
	dev-libs/libdivsufsort"
DEPEND="${RDEPEND}"

src_configure() {
	append-lfs-flags
	tc-export CXX
	export GENTOO_LIBDIR=$(get_libdir)
	makeargs=( USE_BSDIFF=y )
}

src_compile() {
	emake "${makeargs[@]}" all $(usev test)
}

src_install() {
	emake install DESTDIR="${D}" "${makeargs[@]}"
}

pkg_preinst() {
	# We want bsdiff in the sdk and in the sysroot (for testing), but
	# we don't want it in the target image as it isn't used.
	if [[ $(cros_target) == "target_image" ]]; then
		rm "${D}"/usr/bin/bsdiff "${D}"/usr/$(get_libdir)/bsdiff.so
	fi
}
