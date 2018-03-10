# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="f4af55cf302b5fa586e8f8de6c38c626e4c1c15e"
CROS_WORKON_TREE="04fc7bbbe8aa6964b4d08a595f95cfc33f724158"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest/files

inherit cros-workon

DESCRIPTION="Compilation and runtime tests for toolchain"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"

src_unpack() {
	cros-workon_src_unpack
	S+="/client/site_tests/platform_ToolchainTests/src"
}

# cros-run-unit_tests checks the existence of src_test.
# Spell it explictly so that it will be tested.
src_test() {
	default
}
