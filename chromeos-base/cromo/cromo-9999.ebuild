# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_PROJECT="chromiumos/platform/cromo"
CROS_WORKON_USE_VCSID="1"

inherit cros-debug cros-workon toolchain-funcs multilib

DESCRIPTION="Chromium OS modem manager"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="~*"
IUSE="-asan -clang install_tests platform2"
REQUIRED_USE="asan? ( clang )"

LIBCHROME_VERS="180609"

RDEPEND="chromeos-base/chromeos-minijail
	chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	>=dev-libs/glib-2.0
	dev-libs/dbus-glib
	dev-libs/dbus-c++
	dev-cpp/gflags
	dev-cpp/glog
	install_tests? ( dev-cpp/gtest )
	chromeos-base/metrics
	chromeos-base/platform2
"

DEPEND="${RDEPEND}
	chromeos-base/system_api
	virtual/modemmanager"

RDEPEND="!platform2? ( ${RDEPEND} )"
DEPEND="!platform2? ( ${DEPEND} )"

make_flags() {
	echo LIBDIR="/usr/$(get_libdir)" BASE_VER=${LIBCHROME_VERS}
	use install_tests && echo INSTALL_TESTS=1
}

src_prepare() {
	if use platform2; then
		printf '\n\n\n'
		ewarn "This package doesn't install anything with USE=platform2."
		ewarn "You want to use the new chromeos-base/platform2 package."
		printf '\n\n\n'
		return 0
	fi
	cros-workon_src_prepare
}

src_configure() {
	use platform2 && return 0
	clang-setup-env
	cros-workon_src_configure
}

src_compile() {
	use platform2 && return 0

	tc-export CXX AR NM PKG_CONFIG
	cros-debug-add-NDEBUG
	emake $(make_flags)
}

src_test() {
	use platform2 && return 0

	tc-export CXX AR PKG_CONFIG
	cros-debug-add-NDEBUG
	emake $(make_flags) tests
	if ! use x86 && ! use amd64 ; then
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
	use platform2 && return 0

	emake $(make_flags) DESTDIR="${D}" install
}
