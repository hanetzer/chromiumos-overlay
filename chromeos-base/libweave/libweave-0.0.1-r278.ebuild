# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT=("a34f81648ff81edb316aff722c39f3afd41b5149" "fa29d8f43a37aaf4b47fd2f3c76785050d075a7d")
CROS_WORKON_TREE=("94b7b580e731a9fed0bc89afec6afc316dc47172" "25a30fb90c3fffe56f573486a3e04691b25272bb")
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