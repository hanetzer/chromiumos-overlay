# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
CROS_WORKON_PROJECT="chromiumos/third_party/libresample"

inherit cros-workon

DESCRIPTION="resampling library (see README.chromiumos)"
HOMEPAGE="http://www-ccrma.stanford.edu/~jos/resample/"
SRC_URI=""

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~*"
IUSE=""

src_configure() {
	cros-workon_src_configure
}
