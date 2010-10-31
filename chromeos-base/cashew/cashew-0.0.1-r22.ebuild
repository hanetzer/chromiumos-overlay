# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="dba079b6811c1062fc920de0e7f79cc20a3fb407"

inherit cros-workon autotools

DESCRIPTION="Chromium OS network usage tracking daemon"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="test"

RDEPEND="chromeos-base/flimflam
	chromeos-base/libchrome
	dev-cpp/gflags
	dev-cpp/glog
	dev-libs/dbus-c++
	dev-libs/glib
	net-misc/curl"

DEPEND="${RDEPEND}
	test? ( dev-cpp/gtest )"

src_prepare() {
	eautoreconf
}

src_compile() {
	emake clean-generic || die "emake clean failed"
	emake || die "emake failed"
}

src_test() {
	# build and run unit tests
	emake check || die "emake check failed"
	if use x86 ; then
		src/cashew_unittest ${GTEST_ARGS} ||
			die "unit tests (with GTEST_ARGS = ${GTEST_ARGS}) failed!"
	else
		# don't try to run cross-compiled non-x86 unit test binaries in our x86
		# host environment
		echo =====================================
		echo Skipping tests on non-x86 platform...
		echo =====================================
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	# TODO(vlaviano): do the following in autotools `make install` instead?

	# install upstart config file.
	dodir /etc/init
	install --owner=root --group=root --mode=0644 \
		"${S}"/cashew.conf "${D}"/etc/init

	# install D-Bus config file.
	dodir /etc/dbus-1/system.d
	install --owner=root --group=root --mode=0644 \
		"${S}"/org.chromium.Cashew.conf "${D}"/etc/dbus-1/system.d

	# TODO(vlaviano): install introspection xml files somewhere?
}
