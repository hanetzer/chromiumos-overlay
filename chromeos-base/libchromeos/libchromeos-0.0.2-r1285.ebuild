# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT=("a24c43c647200f2bdbd415b9f7340c1905865b03" "49fb1ce7956110497bd7cad33b3a954faca4b77c")
CROS_WORKON_TREE=("ae7cb99c10a1d0019299c1f042e12d30bf862431" "34b7e6c58c262307ed7c6ab16db0514aca7c036a")
CROS_WORKON_BLACKLIST=1
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_USE_VCSID=1
CROS_WORKON_LOCALNAME=("platform2" "aosp/external/libchromeos")
CROS_WORKON_PROJECT=("chromiumos/platform2" "platform/external/libchromeos")
CROS_WORKON_REPO=("https://chromium.googlesource.com" "https://android.googlesource.com")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/platform2/libchromeos")

PLATFORM_SUBDIR="libchromeos"
PLATFORM_NATIVE_TEST="yes"

inherit cros-workon libchrome multilib platform

DESCRIPTION="Base library for Chromium OS"
HOMEPAGE="http://dev.chromium.org/chromium-os/platform"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="cros_host"

COMMON_DEPEND="
	chromeos-base/bootstat
	chromeos-base/chromeos-minijail
	dev-libs/dbus-c++
	dev-libs/dbus-glib
	dev-libs/openssl
	dev-libs/protobuf
	net-misc/curl
	sys-apps/rootdev
"
RDEPEND="
	${COMMON_DEPEND}
	!cros_host? ( chromeos-base/libchromeos-use-flags )
	chromeos-base/chromeos-ca-certificates
"
DEPEND="
	${COMMON_DEPEND}
	chromeos-base/protofiles
	dev-cpp/gtest
	dev-libs/modp_b64
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
		dolib.a "${OUT}"/libchromeos*-"${v}".a
		doins "${OUT}"/lib/libchromeos*-"${v}".pc
	done

	# Install all the header files from libchromeos/chromeos/*.h into
	# /usr/include/chromeos (recursively, with sub-directories).
	local dir
	while read -d $'\0' -r dir; do
		insinto "/usr/include/${dir}"
		doins "${dir}"/*.h
	done < <(find chromeos -type d -print0)

	insinto /usr/include/policy
	doins policy/*.h
}

platform_pkg_test() {
	local v
	for v in "${LIBCHROME_VERS[@]}"; do
		platform_test "run" "${OUT}/libchromeos-${v}_unittests"
		platform_test "run" "${OUT}/libpolicy-${v}_unittests"
	done
}
