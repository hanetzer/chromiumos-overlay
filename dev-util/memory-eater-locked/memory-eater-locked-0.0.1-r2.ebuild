# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_COMMIT="71e236cd2eb8aa7aef05aa0d63c42c21f490c50d"
CROS_WORKON_TREE="4425056a797909be9763dbf52a2b48c7e6ffc7ab"
CROS_WORKON_PROJECT="chromiumos/platform/experimental"
CROS_WORKON_LOCALNAME="../platform/experimental"

inherit cros-workon

DESCRIPTION="A memory consumer to allocate mlocked (non-swappable) memory"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/experimental/+/master/memory-eater-locked/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND=""
DEPEND=""

src_compile() {
	tc-export CC
	emake memory-eater-locked/memory-eater-locked || die "end compile failed."
}

src_install() {
	dobin memory-eater-locked/memory-eater-locked
}
