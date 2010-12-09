# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="Chrome OS Monitor Reconfig"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE=""

DEPEND="chromeos-base/libchrome
	x11-libs/libX11
	x11-libs/libXrandr"

RDEPEND="${DEPEND}
	x11-apps/xrandr"

# TODO(msb): remove this hack
src_unpack() {
	cros-workon_src_unpack
	ln -s "${S}" "${S}/${PN}"
}

src_compile() {
	tc-export CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	pushd monitor_reconfig
	emake monitor_reconfigure || die "monitor_reconfigure compile failed."
	popd
}

src_test() {
	if ! use x86 ; then
		echo Skipping tests on non-x86 platform...
	else
		tc-export CXX PKG_CONFIG
		cros-debug-add-NDEBUG
		pushd monitor_reconfig
		emake test || die "failed to build tests"
		for test in ./*_test; do
			"$test" ${GTEST_ARGS} || die "$test failed"
		done
		popd
	fi
}

src_install() {
	dobin monitor_reconfig/monitor_reconfigure

	# Install the hotplug display configure script.
	exeinto "/lib/udev"
	doexe "${S}/display-configure.sh"

	# Install the hotplug udev rule.
	insinto "/etc/udev/rules.d"
	doins "${S}/99-monitor-hotplug.rules"
}
