# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="4bca6a684acc5c33cf749806d132f76a0217eac0"
CROS_WORKON_PROJECT="chromiumos/platform/cromo"

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="Chromium OS modem manager"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="install_tests"

RDEPEND="chromeos-base/libchrome
	>=dev-libs/glib-2.0
	dev-libs/dbus-glib
	dev-libs/dbus-c++
	dev-cpp/gflags
	dev-cpp/glog
	install_tests? ( dev-cpp/gtest )
	chromeos-base/libchromeos
	chromeos-base/metrics
"

DEPEND="${RDEPEND}
	chromeos-base/system_api
	net-misc/modemmanager"

make_flags() {
	echo PLUGINDIR="/usr/lib/cromo/plugins"
	use install_tests && echo INSTALL_TESTS=1
}

src_compile() {
	tc-export CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	REV=${CROS_WORKON_COMMIT-unknown}
	[ "${REV}" = "master" ] && REV=unknown
	emake $(make_flags) VCSID="${REV}" || die
}

src_test() {
	tc-export CXX AR PKG_CONFIG
	cros-debug-add-NDEBUG
	[ "${REV}" = "master" ] && REV=unknown
	emake $(make_flags) VCSID="${REV}" tests || die "could not build tests"
	if ! use x86; then
		echo Skipping unit tests on non-x86 platform
	else
		for test in ./*_unittest; do
			# TODO: Set up enough DBus so that the server test can work
			# Alternately, run the whole thing in a VM/qemu instance
			if [ ${test} == "./cromo_server_unittest" ]; then
				echo "Skipping server test in host environment"
			else
				echo "Running ${test}"
				"${test}" || die "${test} failed"
			fi
		done
	fi
}

src_install() {
	emake $(make_flags) DESTDIR="${D}" install || die
}
