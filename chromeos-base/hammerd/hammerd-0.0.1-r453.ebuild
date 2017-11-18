# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="a8822d39bbcdd11aa6172f99c1599b0eabe73365"
CROS_WORKON_TREE="3ff39392832a002bc30461533b1f4f48513bd7f5"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"

PLATFORM_SUBDIR="hammerd"
DISTUTILS_OPTIONAL=1
PYTHON_COMPAT=( python2_7 )

inherit cros-workon platform user distutils-r1

DESCRIPTION="A daemon to update EC firmware of hammer, the base of the detachable."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/hammerd/"

LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"
IUSE="python"

DEPEND="
	chromeos-base/libbrillo
	chromeos-base/metrics
	chromeos-base/system_api
	chromeos-base/vboot_reference
	dev-libs/openssl
	python? (
		${PYTHON_DEPS}
		dev-python/setuptools[${PYTHON_USEDEP}]
	)
	sys-apps/flashmap
	virtual/libusb:1
"
RDEPEND="${DEPEND}"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

pkg_preinst() {
	# Create user and group for hammerd
	enewuser "hammerd"
	enewgroup "hammerd"
}

src_prepare() {
	use python && distutils-r1_src_prepare
}

src_install() {
	dobin "${OUT}/hammerd"

	# Install upstart configs and scripts.
	insinto /etc/init
	doins init/*.conf
	exeinto /usr/share/cros/init
	doexe init/*.sh

	# Install exposed API.
	if use python; then
		dolib.so "${OUT}"/lib/libhammerd-api.so
		insinto /usr/include/hammerd/
		doins hammerd_api.h
		distutils-r1_src_install
	fi

	# Install DBus config.
	insinto /etc/dbus-1/system.d
	doins dbus/org.chromium.hammerd.conf
}

platform_pkg_test() {
	platform_test "run" "${OUT}/unittest_runner"
}
