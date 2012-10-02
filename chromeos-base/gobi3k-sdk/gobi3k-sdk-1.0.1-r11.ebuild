# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="af72f885d6b611146358882c79a7fdb5aa5f6b46"
CROS_WORKON_TREE="25d6487274cdea060979374e14e985fde7abbb43"
EAPI="2"

CROS_WORKON_PROJECT="chromiumos/third_party/gobi3k-sdk"
CROS_WORKON_LOCALNAME=../third_party/gobi3k-sdk
inherit cros-workon toolchain-funcs

DESCRIPTION="SDK for Qualcomm Gobi 3000 modems"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

# TODO(jglasgow): remove realpath dependency
RDEPEND="
	app-misc/realpath
"

src_compile () {
	tc-export LD CXX CC OBJCOPY AR
	emake || die Building
}

src_install () {
	emake DESTDIR="${D}" install || die Installing
}
