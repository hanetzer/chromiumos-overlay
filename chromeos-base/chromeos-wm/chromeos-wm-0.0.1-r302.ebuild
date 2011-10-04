# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="0217f2b36ddaae8640427a5283fa113070b381f9"
CROS_WORKON_PROJECT="chromiumos/platform/window_manager"

inherit cros-debug cros-workon flag-o-matic toolchain-funcs

DESCRIPTION="Chrome OS window manager"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="-bogus_screen_resizes opengles -touchui"

RDEPEND="chromeos-base/metrics
	dev-cpp/gflags
	dev-cpp/glog
	dev-libs/libpcre
	dev-libs/protobuf
	media-libs/libpng
	sys-apps/dbus
	x11-libs/cairo
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libxcb
	!opengles? ( virtual/opengl )
	opengles? ( virtual/opengles )"
DEPEND="chromeos-base/libchrome
	chromeos-base/system_api
	dev-libs/vectormath
	${RDEPEND}"
# This is a temporary measure -- files are being moved from this package to the
# crosh package for http://crosbug.com/7741, so we want to merge crosh after
# chromeos-wm to ensure that there's no conflict.
PDEPEND="chromeos-base/crosh"

# Print the number of jobs from $MAKEOPTS.
print_num_jobs() {
	local JOBS=$(echo $MAKEOPTS | sed -nre 's/.*-j\s*([0-9]+).*/\1/p')
	echo ${JOBS:-1}
}

CROS_WORKON_LOCALNAME="window_manager"

src_compile() {
	tc-export CC CXX AR RANLIB LD NM
	cros-debug-add-NDEBUG
	use touchui && append-flags -DTOUCH_UI
	use bogus_screen_resizes && append-flags -DBOGUS_SCREEN_RESIZES
	export CCFLAGS="$CFLAGS"

	local backend
	if use opengles ; then
		backend=OPENGLES
	else
		backend=OPENGL
	fi

	scons BACKEND="$backend" -j$(print_num_jobs) wm screenshot || \
		die "window_manager compile failed"
}

src_test() {
	scons -j$(print_num_jobs) tests || die "failed to build tests"

	if ! use x86 ; then
		echo Skipping tests on non-x86 platform...
	else
		for test in $(find -name '*_test' | sort); do
			"$test" ${GTEST_ARGS} || die "$test failed"
		done
	fi
}

src_install() {
	newbin wm chromeos-wm
	dobin screenshot

	into /
	dosbin bin/window-manager-session.sh
}
