# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=5

CROS_WORKON_COMMIT=("f871d47a1749dce89ab64483527d9c497bdde2e2" "58ffb83ad394baf5a757c2c89c2b111cabffa479")
CROS_WORKON_TREE=("a6e1e2068d626b53215de4023a6dc55c5619d09c" "bcfec7362dd7fe97822d285854cd9957430b54b8")
inherit cros-constants

CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_LOCALNAME=("../platform2" "../platform/puffin")
CROS_WORKON_PROJECT=("chromiumos/platform2" "chromiumos/platform/puffin")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/platform/puffin")
CROS_WORKON_REPO=("${CROS_GIT_HOST_URL}" "${CROS_GIT_HOST_URL}")

PLATFORM_SUBDIR="puffin"

inherit cros-workon platform

DESCRIPTION="Puffin: Deterministic patching tool for deflate streams"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/puffin"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	chromeos-base/libbrillo
	dev-libs/protobuf:=
	dev-util/bsdiff
"

DEPEND="${RDEPEND}"

src_unpack() {
	local s="${S}"
	platform_src_unpack

	# The platform eclass will look for puffin in src/platform2 This forces it
	# to look in src/platform.
	S="${s}/platform/puffin"
}

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
