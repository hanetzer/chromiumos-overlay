# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT=("6b61036fa727cd7436357dc1019056edbb035a2a" "35fb87b830270adaf3b24b18cb43db8debb62bd8")
CROS_WORKON_TREE=("72d926bbaa0bfcde29923fde20bcce263b1915d5" "62157f29289248104185d26f244e2b1c3b51ab55")
CROS_WORKON_BLACKLIST=1
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME=("platform2" "weave/libweave")
CROS_WORKON_PROJECT=("chromiumos/platform2" "weave/libweave")
CROS_WORKON_REPO=("https://chromium.googlesource.com" "https://weave.googlesource.com")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/weave/libweave")

PLATFORM_SUBDIR="libweave"
PLATFORM_GYP_FILE="libweave.gyp"

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
	cp -al "${s}"/platform2/libweave/libweave.gyp "${s}"/weave/libweave/libweave/
	S="${s}/weave/libweave/libweave"
}

src_install() {
	insinto "/usr/$(get_libdir)/pkgconfig"

	# Install libraries.
	local v
	for v in "${LIBCHROME_VERS[@]}"; do
		../../../platform2/libweave/preinstall.sh "${OUT}" "${v}"
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
