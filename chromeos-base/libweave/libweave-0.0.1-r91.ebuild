# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT=("889bb40f1cca0e135a205eeef5ab8a4b9df9ef8a" "e22a73f8b3ec50f34a10dc895ba659801e1d0959")
CROS_WORKON_TREE=("a92b674bf3405d7286e12a7f1bb5e7593f09dcfe" "9ff5a604b7571b7fb84faf314a0b6bb9f56a69f8")
CROS_WORKON_BLACKLIST=1
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME=("platform2" "weave/libweave")
CROS_WORKON_PROJECT=("chromiumos/platform2" "weave/libweave")
CROS_WORKON_REPO=("https://chromium.googlesource.com" "https://weave.googlesource.com")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/weave/libweave")

PLATFORM_SUBDIR="libweave"
PLATFORM_GYP_FILE="platform2.gyp"

inherit cros-workon libchrome platform

DESCRIPTION="Weave device library"
HOMEPAGE="http://dev.chromium.org/chromium-os/platform"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

COMMON_DEPEND="
	chromeos-base/libchromeos
"

RDEPEND="
	${COMMON_DEPEND}
"

DEPEND="
	${COMMON_DEPEND}
	dev-cpp/gmock
	dev-cpp/gtest
"

src_unpack() {
	local s="${S}"
	platform_src_unpack
	S="${s}/weave/libweave/libweave"
}

src_install() {
	insinto "/usr/$(get_libdir)/pkgconfig"

	# Install libraries.
	local v
	for v in "${LIBCHROME_VERS[@]}"; do
		./platform2_preinstall.sh "${OUT}" "${v}"
		dolib.so "${OUT}"/lib/libweave-"${v}".so
		doins "${OUT}"/lib/libweave-*"${v}".pc
		dolib.a "${OUT}"/libweave-test-"${v}".a
	done

	# Install header files.
	insinto /usr/include/weave
	doins include/weave/*.h

	insinto /usr/include/weave/test
	doins include/weave/test/*.h
}

platform_pkg_test() {
	platform_test "run" "${OUT}/libweave_testrunner"
	platform_test "run" "${OUT}/libweave_base_testrunner"
	platform_test "run" "${OUT}/libweave_exports_testrunner"
	platform_test "run" "${OUT}/libweave_base_exports_testrunner"
}
