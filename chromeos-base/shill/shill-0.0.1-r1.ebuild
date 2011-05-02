# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="5a685df6842f98781621489444b010dc79e0170b"

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="Shill Connection Manager for Chromium OS"
HOMEPAGE="http://src.chromium.org"
LICENSE="BSD"
SLOT="0"
IUSE="test"
KEYWORDS="amd64 arm x86"

RDEPEND="dev-cpp/gflags
	dev-cpp/glog"

DEPEND="${RDEPEND}
	chromeos-base/libchrome
	test? ( dev-cpp/gmock )
	test? ( dev-cpp/gtest )"

src_compile() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG

	# TODO(davidjames): parallel builds
	scons || die "shill compile failed."
}

src_test() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG

	# Build tests
	scons tests || die "tests compile failed."

	# Run tests if we're on x86
	if ! use x86 ; then
		echo Skipping tests on non-x86 platform...
	else
		for ut in shill ; do
			"${S}/${ut}_unittest" \
				${GTEST_ARGS} || die "${ut}_unittest failed"
		done
	fi
}

src_install() {
	dobin "shill" || die
	# Install upstart config file
	insinto /etc/init
	doins shill.conf || die
}
