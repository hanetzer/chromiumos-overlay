# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="69702c400e274984a24d08fcaefe3952d5dcb36e"
CROS_WORKON_TREE="c465fd4519dad374fe5acbee8a8948ec1ee16634"
CROS_WORKON_PROJECT="chromiumos/third_party/gobi3k-sdk"
CROS_WORKON_LOCALNAME=../third_party/gobi3k-sdk
inherit cros-workon toolchain-funcs

DESCRIPTION="SDK for Qualcomm Gobi 3000 modems"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

# TODO(jglasgow): remove realpath dependency
RDEPEND="
	|| ( >=sys-apps/coreutils-8.15 app-misc/realpath )
"

src_configure() {
	clang-setup-env
	cros-workon_src_configure
	tc-export LD CXX CC OBJCOPY AR
}
