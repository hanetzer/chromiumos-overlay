# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT=5155f2139e98469b53d7bac1b2f886dd8aa040ec
CROS_WORKON_TREE="2df86239453800acff8e7d8d07f5e26e5d846a54"

EAPI=4
CROS_WORKON_PROJECT="chromiumos/platform/login_manager"

KEYWORDS="arm amd64 x86"

LIBCHROME_VERS="125070"

inherit cros-debug cros-workon multilib toolchain-funcs

DESCRIPTION="Login manager for Chromium OS."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"

# Boards whose USE flags we write for session_manager_setup.sh.
BOARDS=(
	daisy
	ironhide
	x86-alex
	x86-alex_he
	x86-alex32
	x86-alex32_he
	x86-mario
	x86-zgb
	x86-zgb_he
	x86-zgb32
	x86-zgb32_he
)
BOARD_USE_PREFIX="board_use_"
BOARD_USE_FLAGS=${BOARDS[@]/#/${BOARD_USE_PREFIX}}

PKG_IUSE="-asan -aura -disable_login_animations -disable_oobe_animation
	  -disable_webaudio -highdpi -is_desktop -new_power_button test -touchui +X"
IUSE="${PKG_IUSE} ${BOARD_USE_FLAGS}"

RDEPEND="chromeos-base/chromeos-cryptohome
	chromeos-base/chromeos-minijail
	chromeos-base/metrics
	dev-libs/dbus-glib
	dev-libs/glib
	dev-libs/nss
	dev-libs/protobuf
	sys-apps/util-linux"

DEPEND="${RDEPEND}
	chromeos-base/bootstat
	chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	>=chromeos-base/libchrome_crypto-${LIBCHROME_VERS}
	chromeos-base/protofiles
	chromeos-base/system_api
	dev-cpp/gmock
	sys-libs/glibc
	test? ( dev-cpp/gtest )"

CROS_WORKON_LOCALNAME="$(basename ${CROS_WORKON_PROJECT})"

src_prepare() {
	if ! use X; then
		epatch "${FILESDIR}"/0001-Remove-X-from-session_manager_setup.sh.patch
	fi
}

src_compile() {
	tc-export CXX LD PKG_CONFIG
	cros-debug-add-NDEBUG
	emake login_manager || die "chromeos-login compile failed."

	# Build locale-archive for Chrome. This is a temporary workaround for
	# crbug.com/116999.
	# TODO(yusukes): Fix Chrome and remove the file.
	mkdir -p "${T}/usr/lib64/locale"
	localedef --prefix="${T}" -c -f UTF-8 -i en_US en_US.UTF-8 || die
}

src_test() {
	tc-export CXX LD PKG_CONFIG
	cros-debug-add-NDEBUG
	append-cppflags -DUNIT_TEST
	emake tests || die "chromeos-login compile tests failed."
}

src_install() {
	into /
	dosbin "${S}/keygen"
	dosbin "${S}/session_manager_setup.sh"
	dosbin "${S}/session_manager"
	dosbin "${S}/xstart.sh"

	insinto /usr/share/dbus-1/interfaces
	doins "${S}/session_manager.xml"

	insinto /etc/dbus-1/system.d
	doins "${S}/SessionManager.conf"

	insinto /usr/share/dbus-1/services
	doins "${S}/org.chromium.SessionManager.service"

	insinto /usr/share/misc
	doins "${S}/recovery_ui.html"

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
	local flags=( ${PKG_IUSE} ${BOARD_USE_FLAGS} )
	local flag
	for flag in ${flags[@]/#[-+]} ; do
		usev ${flag}
	done > "${use_flag_file}"
}
