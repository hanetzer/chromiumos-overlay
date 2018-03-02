# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=5

CROS_WORKON_COMMIT=("acb5e27c7fba97d918783efbf8f879d192c6b299" "dc5d7972899ec1ab38a3b3a2aa424802b05ea4b1")
CROS_WORKON_TREE=("d2f52dbb2c258e86eadcfae8f2a43b6d4de59ebe" "49ce7bafe0791566fb81b49291df98d9e7c1c329")
inherit cros-constants

CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_LOCALNAME=("../platform2" "../aosp/external/puffin")
CROS_WORKON_PROJECT=("chromiumos/platform2" "platform/external/puffin")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/platform2/puffin")
CROS_WORKON_REPO=("${CROS_GIT_HOST_URL}" "${CROS_GIT_AOSP_URL}")
CROS_WORKON_SUBTREE=("common-mk" "")
CROS_WORKON_BLACKLIST=1
# We may need to blacklist this ebuild at some point, but it not totally
# necessary right now.

PLATFORM_SUBDIR="puffin"

inherit cros-workon platform

DESCRIPTION="Puffin: Deterministic patching tool for deflate streams"
HOMEPAGE="https://android.googlesource.com/platform/external/puffin/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="asan fuzzer"

RDEPEND="
	chromeos-base/libbrillo[asan?,fuzzer?]
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

	platform_fuzzer_install "${OUT}"/puffin_fuzzer
}

platform_pkg_test() {
	platform_test "run" "${OUT}/puffin_unittest"

	# Run fuzzer.
	platform_fuzzer_test "${OUT}"/puffin_fuzzer
}

pkg_preinst() {
	# We only want libpuffpatch.so in runtime images.
	if [[ $(cros_target) == "target_image" ]]; then
		rm "${D}"/usr/bin/puffin "${D}"/usr/$(get_libdir)/puffdiff.so
	fi
}
