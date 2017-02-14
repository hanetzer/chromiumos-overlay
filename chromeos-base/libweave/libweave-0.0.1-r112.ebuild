# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT=("8023c5258ff12b29ea870968fa8281d0fd7c1bcd" "07b26e3d000973a184087e882d71d66494498f85")
CROS_WORKON_TREE=("d68b887564dd8b832e9f0d77f01973d29dfedcef" "c70b22e257ec34bbde0c6c6f472db30a564c8b7c")
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

RDEPEND="
"

DEPEND="
	dev-cpp/gmock
	dev-cpp/gtest
"

src_unpack() {
	local s="${S}"
	platform_src_unpack
	cp -al "${s}"/platform2/libweave/libweave.gyp "${s}"/weave/libweave/
	S="${s}/weave/libweave/"
}

src_install() {
	insinto "/usr/$(get_libdir)/pkgconfig"

	# Install libraries.
	local v
	for v in "${LIBCHROME_VERS[@]}"; do
		../../platform2/libweave/preinstall.sh "${OUT}" "${v}"
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
}
