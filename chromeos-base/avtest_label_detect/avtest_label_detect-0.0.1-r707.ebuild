# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=4

CROS_WORKON_COMMIT="6272f93a7c24b84e9f4c5b154f887d58ee02df9c"
CROS_WORKON_TREE="8bcd7622f5b50ff279f4eaa02ebd0b0a91d2fcc6"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_DESTDIR="${S}"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon eutils

DESCRIPTION="Autotest label detector for audio/video/camera"
HOMEPAGE="http://src.chromium.org"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang vaapi"
REQUIRED_USE="asan? ( clang )"

RDEPEND="vaapi? ( x11-libs/libva )"
DEPEND="${RDEPEND}"

src_unpack() {
	cros-workon_src_unpack
	S+="/avtest_label_detect"
}

src_prepare() {
	cros-workon_src_prepare
}

src_configure() {
	export USE_VAAPI=$(usex vaapi)
	clang-setup-env
	cros-workon_src_configure
}

src_compile() {
	cros-workon_src_compile
}

src_install() {
	cros-workon_src_install

	# Install built tools
	pushd "${OUT}" >/dev/null
	dobin avtest_label_detect
	popd >/dev/null
}
