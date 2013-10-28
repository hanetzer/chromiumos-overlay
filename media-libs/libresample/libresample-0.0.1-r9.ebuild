# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
CROS_WORKON_COMMIT="cc9f20f439396b7d45e94b8301edd95d33f26a46"
CROS_WORKON_TREE="172744c4f8686f99baa15072d6e47716ff67e6e9"
CROS_WORKON_PROJECT="chromiumos/third_party/libresample"

inherit cros-workon

DESCRIPTION="resampling library (see README.chromiumos)"
HOMEPAGE="http://www-ccrma.stanford.edu/~jos/resample/"
SRC_URI=""

LICENSE="LGPL"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
IUSE=""

src_configure() {
	cros-workon_src_configure
}
