# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT=("5815153e08968525ff97d40873433dce7b930988" "b93979c05d099d54f997720190e5b7b4f84b5366")
CROS_WORKON_TREE=("98b12f942c14e1c3a136b8606b2d4ba6c31222cc" "ffd8bdcf77e2b47a205ba3f0ede518600babd826")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_USE_VCSID=1
CROS_WORKON_LOCALNAME=("platform2" "aosp/external/libbrillo")
CROS_WORKON_PROJECT=("chromiumos/platform2" "aosp/platform/external/libbrillo")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/platform2/libbrillo")

PLATFORM_SUBDIR="libbrillo"
PLATFORM_NATIVE_TEST="yes"

inherit cros-workon libchrome multilib platform

DESCRIPTION="Base library for Chromium OS"
HOMEPAGE="http://dev.chromium.org/chromium-os/platform"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="cros_host +dbus"

COMMON_DEPEND="
	chromeos-base/bootstat
	chromeos-base/chromeos-minijail
	dbus? ( dev-libs/dbus-glib )
	dev-libs/openssl
	dev-libs/protobuf
	net-misc/curl
	sys-apps/rootdev
"
RDEPEND="
	${COMMON_DEPEND}
	!cros_host? ( chromeos-base/libchromeos-use-flags )
	chromeos-base/chromeos-ca-certificates
	!chromeos-base/libchromeos
"
DEPEND="
	${COMMON_DEPEND}
	chromeos-base/protofiles
	dev-libs/modp_b64
"

src_install() {
	local v
	insinto "/usr/$(get_libdir)/pkgconfig"
	for v in "${LIBCHROME_VERS[@]}"; do
		./platform2_preinstall.sh "${OUT}" "${v}"
		dolib.so "${OUT}"/lib/lib{brillo,installattributes,policy}*-"${v}".so
		dolib.a "${OUT}"/libbrillo*-"${v}".a
		doins "${OUT}"/lib/libbrillo*-"${v}".pc
	done

	# Install all the header files from libbrillo/brillo/*.h into
	# /usr/include/brillo (recursively, with sub-directories).
	local dir
	while read -d $'\0' -r dir; do
		insinto "/usr/include/${dir}"
		doins "${dir}"/*.h
	done < <(find brillo -type d -print0)

	insinto /usr/include/policy
	doins policy/*.h
	insinto /usr/include/install_attributes
	doins install_attributes/libinstallattributes.h
}

platform_pkg_test() {
	local v
	for v in "${LIBCHROME_VERS[@]}"; do
		platform_test "run" "${OUT}/libbrillo-${v}_unittests"
		platform_test "run" "${OUT}/libinstallattributes-${v}_unittests"
		platform_test "run" "${OUT}/libpolicy-${v}_unittests"
	done
}
