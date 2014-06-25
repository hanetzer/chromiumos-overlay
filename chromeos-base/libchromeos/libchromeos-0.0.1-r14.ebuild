# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="351e9a81f2f2c73a7110fb7e31dbf39578b2bb22"
CROS_WORKON_TREE="8e38e323dec5b771e60595b13323e441647e5cf4"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_USE_VCSID=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"

PLATFORM_SUBDIR="libchromeos"
PLATFORM_NATIVE_TEST="yes"

inherit cros-workon multilib platform

DESCRIPTION="Base library for Chromium OS"
HOMEPAGE="http://dev.chromium.org/chromium-os/platform"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="cros_host"

COMMON_DEPEND="
	chromeos-base/bootstat
	!<chromeos-base/platform2-0.0.2
	dev-libs/dbus-c++
	dev-libs/dbus-glib
	dev-libs/openssl
	dev-libs/protobuf
"
RDEPEND="
	${COMMON_DEPEND}
	!cros_host? ( chromeos-base/libchromeos-use-flags )
"
DEPEND="
	${COMMON_DEPEND}
	dev-cpp/gtest
	test? (
		app-shells/dash
		dev-cpp/gmock
	)
"

src_install() {
	local v
	insinto "/usr/$(get_libdir)/pkgconfig"
	for v in "${LIBCHROME_VERS[@]}"; do
		./platform2_preinstall.sh "${OUT}" "${v}"
		dolib.so "${OUT}"/lib/lib{chromeos,policy}*-"${v}".so
		doins "${OUT}"/lib/libchromeos-"${v}".pc
	done

	local dir dirs=( . dbus glib ui )
	for dir in "${dirs[@]}"; do
		insinto "/usr/include/chromeos/${dir}"
		doins "chromeos/${dir}"/*.h
	done

	insinto /usr/include/policy
	doins chromeos/policy/*.h
}

platform_pkg_test() {
	local v
	for v in "${LIBCHROME_VERS[@]}"; do
		platform_test "run" "${OUT}/libchromeos-${v}_unittests"
		platform_test "run" "${OUT}/libpolicy-${v}_unittests"
	done
}
