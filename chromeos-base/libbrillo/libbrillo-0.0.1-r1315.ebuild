# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT=("7c498abb24715ef8cb730bc2f643574d9c786227" "7859c4ff82e9e42eeb59ff000c379e293a721ed7")
CROS_WORKON_TREE=("99d4f98c0151c7e25437bb625f114bde347170d5" "80cb41fd8434f6222164fe16264a2c45d3a404df")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_USE_VCSID=1
CROS_WORKON_LOCALNAME=("platform2" "aosp/external/libbrillo")
CROS_WORKON_PROJECT=("chromiumos/platform2" "aosp/platform/external/libbrillo")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/platform2/libbrillo")
CROS_WORKON_SUBTREE=("common-mk" "")

PLATFORM_SUBDIR="libbrillo"
PLATFORM_NATIVE_TEST="yes"

inherit cros-workon libchrome multilib platform

DESCRIPTION="Base library for Chromium OS"
HOMEPAGE="http://dev.chromium.org/chromium-os/platform"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0/${PV}.0"
KEYWORDS="*"
IUSE="cros_host +dbus"

COMMON_DEPEND="
	chromeos-base/minijail
	dbus? ( dev-libs/dbus-glib )
	dev-libs/openssl
	dev-libs/protobuf:=
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
	dbus? ( chromeos-base/system_api )
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
