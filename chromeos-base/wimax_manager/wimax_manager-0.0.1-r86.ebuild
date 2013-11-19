# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="d6228dfa7d39fae9b1abac8dc910bbcbff4a98a8"
CROS_WORKON_TREE="a04abd4e180b80b51588b7d128201531f50cdc4b"
CROS_WORKON_PROJECT="chromiumos/platform/wimax_manager"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-debug cros-workon

DESCRIPTION="Chromium OS WiMAX Manager"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
IUSE="-asan -clang gdmwimax platform2 test"
REQUIRED_USE="asan? ( clang )"

LIBCHROME_VERS="180609"

RDEPEND="gdmwimax? (
	chromeos-base/libchromeos
	chromeos-base/metrics
	chromeos-base/platform2
	dev-libs/dbus-c++
	>=dev-libs/glib-2.30
	dev-libs/protobuf
	virtual/gdmwimax
)"

DEPEND="gdmwimax? (
	${RDEPEND}
	chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	chromeos-base/system_api
	test? ( dev-cpp/gmock )
	test? ( dev-cpp/gtest )
)"

RDEPEND="!platform2? ( ${RDEPEND} )"
DEPEND="!platform2? ( ${DEPEND} )"

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
	use gdmwimax || return 0
	cros-workon_src_compile
}

src_test() {
	use platform2 && return 0
	use gdmwimax || return 0

	# Needed for `cros_run_unit_tests`.
	cros-workon_src_test
}

src_install() {
	use platform2 && return 0

	cros-workon_src_install
	# Install D-Bus introspection XML files.
	insinto /usr/share/dbus-1/interfaces
	doins dbus_bindings/org.chromium.WiMaxManager*.xml

	# Skip the rest of the files unless USE=gdmwimax is specified.
	use gdmwimax || return 0

	# Install daemon executable.
	dosbin "${OUT}"/wimax-manager

	# Install WiMAX Manager default config file.
	insinto /usr/share/wimax-manager
	doins default.conf

	# Install upstart config file.
	insinto /etc/init
	doins wimax_manager.conf

	# Install D-Bus config file.
	insinto /etc/dbus-1/system.d
	doins dbus_bindings/org.chromium.WiMaxManager.conf
}
