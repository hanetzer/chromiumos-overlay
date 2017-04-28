# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT=("0eeed993adc5f6c4165264caa80328e1a11b5bdd" "9f828fa1e258fc1d3e91926c15b64dfd9f666e54")
CROS_WORKON_TREE=("28f000a6c927ec410937bd257bf3bc31a9d58537" "71c358e9dbaeb333370306e9da4a2445991c1554")
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
