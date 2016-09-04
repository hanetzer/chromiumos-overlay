# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=4

CROS_WORKON_COMMIT="8d7b0325a7ada1ebc3cdc44da6ac81b877f6f016"
CROS_WORKON_TREE="d29d019b6e5b10e04138352a7645492896462859"
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

	insinto /etc
	doins "${S}"/avtest_label_detect.conf
}
