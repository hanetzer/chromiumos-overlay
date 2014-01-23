# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="62389179a09d15127728024b82a74ccf07db3dfe"
CROS_WORKON_TREE="1e8ef6aa3f78d3b5b4088235cf08bb6b66568e45"
CROS_WORKON_PROJECT="chromiumos/platform/factory_test_init"

inherit cros-workon

DESCRIPTION="Upstart jobs for the Chrome OS factory test image"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
IUSE=""

DEPEND=""
RDEPEND=""

CROS_WORKON_LOCALNAME="factory_test_init"
