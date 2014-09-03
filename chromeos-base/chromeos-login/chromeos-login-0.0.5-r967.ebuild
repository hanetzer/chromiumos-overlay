# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="6d59475f3808ff91572bb3000d86fc3bd4ebafdb"
CROS_WORKON_TREE="0e48a6f47642b2ccce8e8022f958ab27265d7e14"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"

PLATFORM_SUBDIR="login_manager"

inherit cros-workon libchrome platform

DESCRIPTION="Login manager for Chromium OS."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="chromeos-base/bootstat
	chromeos-base/chromeos-cryptohome
	chromeos-base/chromeos-minijail
	chromeos-base/libchromeos
	chromeos-base/metrics
	dev-libs/glib
	dev-libs/nss
	dev-libs/protobuf
	sys-apps/util-linux"

DEPEND="${RDEPEND}
	>=chromeos-base/libchrome_crypto-${LIBCHROME_VERS}
	chromeos-base/protofiles
	chromeos-base/system_api
	chromeos-base/vboot_reference
	sys-libs/glibc
	test? ( dev-cpp/gmock )
	test? ( dev-cpp/gtest )"

src_compile() {
	platform_src_compile

	# Build locale-archive for Chrome. This is a temporary workaround for
	# crbug.com/116999.
	# TODO(yusukes): Fix Chrome and remove the file.
	mkdir -p "${T}/usr/lib64/locale"
	localedef --prefix="${T}" -c -f UTF-8 -i en_US en_US.UTF-8 || die
}

platform_pkg_test() {
	local tests=( session_manager_test )

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}

src_install() {
	into /
	dosbin "${OUT}/keygen"
	dosbin "${OUT}/session_manager"

	insinto /usr/share/dbus-1/interfaces
	doins org.chromium.SessionManagerInterface.xml

	insinto /etc/dbus-1/system.d
	doins SessionManager.conf

	# Adding init scripts
	insinto /etc/init
	doins init/*.conf

	# TODO(yusukes): Fix Chrome and remove the file. See my comment above.
	insinto /usr/$(get_libdir)/locale
	doins "${T}/usr/lib64/locale/locale-archive"

	# For user session processes.
	dodir /etc/skel/log

	# For user NSS database
	diropts -m0700
	# Need to dodir each directory in order to get the opts right.
	dodir /etc/skel/.pki
	dodir /etc/skel/.pki/nssdb
	# Yes, the created (empty) DB does work on ARM, x86 and x86_64.
	certutil -N -d "sql:${D}/etc/skel/.pki/nssdb" -f <(echo '') || die

	insinto /etc
	doins chrome_dev.conf
}
