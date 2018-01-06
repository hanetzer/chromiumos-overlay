# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=5

CROS_WORKON_COMMIT=("793ba6e895f57c9b781683c64e9c28aa7c25d33e" "12ed900ea8f3788641d58384e5f00f907070386f")
CROS_WORKON_TREE=("ef6439d566763b50b7207d69c73126a57a7dce10" "c233aa3bffcc798a96581c1d1a209fc61c7e440b")
inherit cros-constants

CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_LOCALNAME=("../platform2" "../aosp/external/puffin")
CROS_WORKON_PROJECT=("chromiumos/platform2" "platform/external/puffin")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/platform2/puffin")
CROS_WORKON_REPO=("${CROS_GIT_HOST_URL}" "${CROS_GIT_AOSP_URL}")
# We may need to blacklist this ebuild at some point, but it not totally
# necessary right now.

PLATFORM_SUBDIR="puffin"

inherit cros-workon platform

DESCRIPTION="Puffin: Deterministic patching tool for deflate streams"
HOMEPAGE="https://android.googlesource.com/platform/external/puffin/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	chromeos-base/libbrillo
	dev-libs/protobuf:=
	dev-util/bsdiff
"

DEPEND="${RDEPEND}"

src_install() {
	dobin "${OUT}"/puffin
	dolib.so "${OUT}"/lib/libpuffpatch.so
	dolib.so "${OUT}"/lib/libpuffdiff.so

	insinto /usr/include
	doins -r src/include/puffin/

	insinto "/usr/$(get_libdir)/pkgconfig"
	doins libpuffdiff.pc libpuffpatch.pc
}

platform_pkg_test() {
	platform_test "run" "${OUT}/puffin_unittest"
}

pkg_preinst() {
	# We only want libpuffpatch.so in runtime images.
	if [[ $(cros_target) == "target_image" ]]; then
		rm "${D}"/usr/bin/puffin "${D}"/usr/$(get_libdir)/puffdiff.so
	fi
}
