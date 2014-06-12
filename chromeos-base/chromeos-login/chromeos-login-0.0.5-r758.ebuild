# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="d304386cfb299c925361ad617d69a94de1604ff1"
CROS_WORKON_TREE="b90b05096919b6e80a3f5aacf743ffd3a5d3d2e9"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"

inherit cros-debug cros-workon cros-board multilib toolchain-funcs

DESCRIPTION="Login manager for Chromium OS."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
# NB: Flags listed here are off by default unless prefixed with a '+'.
# This list is lengthy since it determines the USE flags that will be written to
# the /etc/session_manager_use_flags.txt file that's used to generate Chrome's
# command line.
IUSE="asan clang deep_memory_profiler disable_login_animations
	disable_webaudio egl exynos fade_boot_splash_screen
	gpu_sandbox_allow_sysv_shm
	gpu_sandbox_start_after_initialization
	has_diamond_key has_hdd highdpi legacy_keyboard
	legacy_power_button moblab natural_scroll_default ozone
	ozone_platform_dri test +X"
REQUIRED_USE="asan? ( clang )"

LIBCHROME_VERS="271506"

RDEPEND="chromeos-base/chromeos-cryptohome
	!<chromeos-base/chromeos-init-0.0.14
	chromeos-base/chromeos-minijail
	chromeos-base/platform2
	dev-libs/glib
	dev-libs/nss
	dev-libs/protobuf
	sys-apps/util-linux"

DEPEND="${RDEPEND}
	chromeos-base/bootstat
	chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	>=chromeos-base/libchrome_crypto-${LIBCHROME_VERS}
	chromeos-base/protofiles
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

	# Write a list of currently-set USE flags that session_manager_setup.sh can
	# read at runtime while constructing Chrome's command line.  If you need to
	# use a new flag, add it to $IUSE at the top of the file and list it here.
	local use_flag_file="${D}/etc/session_manager_use_flags.txt"
	local flags=( ${IUSE} )
	local flag
	for flag in ${flags[@]/#[-+]} ; do
		usev ${flag}
	done > "${use_flag_file}"

	insinto /etc
	doins chrome_dev.conf
}
