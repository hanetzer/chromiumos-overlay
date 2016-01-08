# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT=("f6cf9ac6d0ff7ada322f310ecb594fe323b6322b" "bd0dc3c259a6da35a17d5fa6962b25b6a52a1a3d")
CROS_WORKON_TREE=("7dae0b54df35f300e201c2c9abe0d7ca87299de4" "f06f46011644232134f40e76f0304ca87d4c659b")
CROS_WORKON_BLACKLIST=1
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/aosp/system/tpm")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME=("platform2" "aosp/system/tpm")
CROS_WORKON_PROJECT=("chromiumos/platform2" "platform/system/tpm")
CROS_WORKON_REPO=("https://chromium.googlesource.com" "https://android.googlesource.com")
CROS_WORKON_USE_VCSID=1

PLATFORM_SUBDIR="trunks"

inherit cros-workon platform user

DESCRIPTION="Trunks service for Chromium OS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="ftdi_tpm test"

RDEPEND="
	chromeos-base/chromeos-minijail
	chromeos-base/libbrillo
	ftdi_tpm? ( dev-embedded/libftdi )
	"

DEPEND="
	${RDEPEND}
	test? ( dev-cpp/gmock )
	dev-cpp/gtest
	"

src_unpack() {
	local s="${S}"
	platform_src_unpack
	S="${s}/aosp/system/tpm/trunks"
}

src_install() {
	insinto /etc/dbus-1/system.d
	doins org.chromium.Trunks.conf

	insinto /etc/init
	doins trunksd.conf

	dosbin "${OUT}"/trunks_client
	dosbin "${OUT}"/trunksd
	dolib.so "${OUT}"/lib/libtrunks.so
	dolib.a "${OUT}"/libtrunks_test.a

	insinto /usr/share/policy
	newins trunksd-seccomp-${ARCH}.policy trunksd-seccomp.policy

	insinto /usr/include/trunks
	doins *.h
}

platform_pkg_test() {
	"${S}/generator/generator_test.py" || die

	local tests=(
		trunks_testrunner
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}

pkg_preinst() {
	enewuser trunks
	enewgroup trunks
}
