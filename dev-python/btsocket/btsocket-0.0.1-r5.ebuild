# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="fc5a3f747da3bf6296497c9f2c424ea7db9f51af"
CROS_WORKON_TREE="de7d8ed6bae941bf2012f2fe61b1a2fc8fa24441"
CROS_WORKON_PROJECT="chromiumos/platform/btsocket"
CROS_WORKON_LOCALNAME="../platform/btsocket"
PYTHON_DEPEND="2"

inherit cros-workon distutils python

DESCRIPTION="Bluetooth Socket support module"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-3"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

src_configure() {
	clang-setup-env
	cros-workon_src_configure
}
