# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="755314d877a4bd97ffc1c9067d7311fc2604df7d"
CROS_WORKON_TREE="18fadd2dbc1d9f83d8f2b83b1d493f0f50159e66"
CROS_WORKON_PROJECT="chromiumos/platform/login_manager"

inherit cros-debug cros-workon cros-board multilib toolchain-funcs

DESCRIPTION="Login manager for Chromium OS."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="arm amd64 x86"
IUSE="-asan -clang -deep_memory_profiler -disable_login_animations
	-disable_webaudio -egl -exynos -fade_boot_splash_screen
	-gpu_sandbox_allow_sysv_shm
	-gpu_sandbox_start_after_initialization
	-has_diamond_key -has_hdd -highdpi -legacy_keyboard
	-legacy_power_button -natural_scroll_default test +X"
REQUIRED_USE="asan? ( clang )"

LIBCHROME_VERS="242728"

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
	dev-cpp/gmock
	sys-libs/glibc
	test? ( dev-cpp/gtest )"

CROS_WORKON_LOCALNAME="$(basename ${CROS_WORKON_PROJECT})"

src_prepare() {
	if ! use X; then
		epatch "${FILESDIR}"/0001-Remove-X-from-session_manager_setup.sh.patch
	fi
}

src_configure() {
	clang-setup-env
	cros-workon_src_configure
}

src_compile() {
	cros-workon_src_compile

	# Build locale-archive for Chrome. This is a temporary workaround for
	# crbug.com/116999.
	# TODO(yusukes): Fix Chrome and remove the file.
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
	dosbin session_manager_setup.sh
	dosbin session_manager
	dosbin xstart.sh
	dobin cros-xauth

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
	nsscertutil -N -d "sql:${D}/etc/skel/.pki/nssdb" -f <(echo '') || die

	# Write a list of currently-set USE flags that session_manager_setup.sh can
	# read at runtime while constructing Chrome's command line.  If you need to
	# use a new flag, add it to $IUSE at the top of the file and list it here.
	local use_flag_file="${D}"/etc/session_manager_use_flags.txt
	local flags=( ${IUSE} )
	local flag
	for flag in ${flags[@]/#[-+]} ; do
		usev ${flag}
	done > "${use_flag_file}"
}
