# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=5

CROS_WORKON_COMMIT=("0e907610b4fb3410c819a887819361a6a6a7fa64" "4b86b6d460b971701f9c8565b580051bdd17d8b6")
CROS_WORKON_TREE=("f6bba004afde8952dffaf2a1c919f5a875ad3ab6" "b391d19985cc8f8c45d7c015f5299a0fa58d1e95")
inherit cros-constants

CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_LOCALNAME=("../platform2" "../aosp/external/puffin")
CROS_WORKON_PROJECT=("chromiumos/platform2" "platform/external/puffin")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/platform2/puffin")
CROS_WORKON_REPO=("${CROS_GIT_HOST_URL}" "${CROS_GIT_AOSP_URL}")
CROS_WORKON_SUBTREE=("common-mk" "")
# We may need to blacklist this ebuild at some point, but it not totally
# necessary right now.

PLATFORM_SUBDIR="puffin"

inherit cros-workon platform

DESCRIPTION="Puffin: Deterministic patching tool for deflate streams"
HOMEPAGE="https://android.googlesource.com/platform/external/puffin/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="fuzzer"

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
