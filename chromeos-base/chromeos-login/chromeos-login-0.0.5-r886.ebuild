# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="a53886fc7655d21c4e5b1d922c16d7e3499125c5"
CROS_WORKON_TREE="773b63c74779d27d7ebe68147dae969aaced768d"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"

inherit cros-debug cros-workon cros-board libchrome multilib toolchain-funcs

DESCRIPTION="Login manager for Chromium OS."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="asan clang test"
REQUIRED_USE="asan? ( clang )"

RDEPEND="chromeos-base/chromeos-cryptohome
	chromeos-base/chromeos-minijail
	chromeos-base/libchromeos
	chromeos-base/metrics
	dev-libs/glib
	dev-libs/nss
	dev-libs/protobuf
	sys-apps/util-linux"

DEPEND="${RDEPEND}
	chromeos-base/bootstat
	>=chromeos-base/libchrome_crypto-${LIBCHROME_VERS}
	chromeos-base/protofiles
	chromeos-base/system_api
	chromeos-base/vboot_reference
	dev-cpp/gmock
	sys-libs/glibc
	test? ( dev-cpp/gtest )"

src_unpack() {
	cros-workon_src_unpack
	S+="/login_manager"
}

src_configure() {
	clang-setup-env
	cros-workon_src_configure
}

src_compile() {
	cros-workon_src_compile

	# Build locale-archive for Chrome.
	mkdir -p "${T}/usr/lib64/locale"
	localedef --prefix="${T}" -c -f UTF-8 -i en_US en_US.UTF-8 || die
}

src_test() {
	append-cppflags -DUNIT_TEST
	cros-workon_src_test
}

src_install() {
	cros-workon_src_install
	into /
	dosbin keygen
	dosbin session_manager
	# TODO(derat): Remove this stub after 20140801.
	dosbin session_manager_setup.sh

	insinto /usr/share/dbus-1/interfaces
	doins org.chromium.SessionManagerInterface.xml

	insinto /etc/dbus-1/system.d
	doins SessionManager.conf

	# Adding init scripts
	insinto /etc/init
	doins init/*.conf

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
