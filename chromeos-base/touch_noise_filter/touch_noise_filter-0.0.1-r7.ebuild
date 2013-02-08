# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="a78c2440333ca1fd3af5ab2f37c0e417dcd9419e"
CROS_WORKON_TREE="d94a7aa4b43294e4fe5d0d56cf5cd61d209f3127"
CROS_WORKON_PROJECT="chromiumos/platform/touch_noise_filter"
CROS_WORKON_USE_VCSID=1

inherit toolchain-funcs multilib cros-debug cros-workon

DESCRIPTION="Touch noise filter"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

LIBCHROME_VERS="125070"

RDEPEND="chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]"
DEPEND="${RDEPEND}"

src_compile() {
	tc-export CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	export BASE_VER=${LIBCHROME_VERS}
	export LIBDIR="/usr/$(get_libdir)"

	emake clean  # TODO(adlr): remove when a better solution exists
	emake
}
