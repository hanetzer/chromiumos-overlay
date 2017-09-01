# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=4

CROS_WORKON_COMMIT="dcf51f7f2e53f370f1b005d6b7b0aeebfd73b82d"
CROS_WORKON_TREE="58672e134745c2c69b77587edd68ca4b8f3d4894"
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
IUSE="-asan vaapi"

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
	asan-setup-env
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
