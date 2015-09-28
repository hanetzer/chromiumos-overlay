# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT=("13b93fcdbcfc4dec24ec0d1e94659774c1de112f" "35f317dacc5176ccc8a7b2b80eeb518ed1f632cd")
CROS_WORKON_TREE=("90f37412e75a351ac9e75cdd3c01e9b752608640" "1a03b724151e7f304125652dd03a7bfdd0f4e047")
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
	insinto /usr/include/weave/
	doins -r include/weave/*
}

platform_pkg_test() {
	platform_test "run" "${OUT}/libweave_testrunner"
	platform_test "run" "${OUT}/libweave_base_testrunner"
	platform_test "run" "${OUT}/libweave_exports_testrunner"
	platform_test "run" "${OUT}/libweave_base_exports_testrunner"
}
