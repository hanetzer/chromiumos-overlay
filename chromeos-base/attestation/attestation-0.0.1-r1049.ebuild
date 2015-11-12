# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT=("d4629233bb3ebaba57d8e8de5107fc748a00bc90" "b3c9cdcef463064d7ac8f1e6b4b88e62433f9d5d")
CROS_WORKON_TREE=("5eccb20df5a4ea8b6c4c1415b2126e60e3fe17bf" "febe3db56bf6f20af5f2f9ad7e6e3becb88a8a0c")
CROS_WORKON_BLACKLIST=1
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/aosp/system/attestation")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME=("platform2" "aosp/system/attestation")
CROS_WORKON_PROJECT=("chromiumos/platform2" "platform/system/attestation")
CROS_WORKON_REPO=("https://chromium.googlesource.com" "https://android.googlesource.com")

PLATFORM_SUBDIR="attestation"

inherit cros-workon libchrome platform user

DESCRIPTION="Attestation service for Chromium OS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	app-crypt/trousers
	chromeos-base/chaps
	chromeos-base/chromeos-minijail
	chromeos-base/libbrillo
	"

DEPEND="
	${RDEPEND}
	test? ( dev-cpp/gmock )
	dev-cpp/gtest
	"

pkg_preinst() {
	# Create user and group for attestation.
	enewuser "attestation"
	enewgroup "attestation"
}

src_unpack() {
	local s="${S}"
	platform_src_unpack
	S="${s}/aosp/system/attestation"
}

src_install() {
	insinto /etc/dbus-1/system.d
	doins server/org.chromium.Attestation.conf

	insinto /etc/init
	doins server/attestationd.conf

	dosbin "${OUT}"/attestationd
	dobin "${OUT}"/attestation_client
	dolib.so "${OUT}"/lib/libattestation.so

	insinto /usr/share/policy
	newins server/attestationd-seccomp-${ARCH}.policy attestationd-seccomp.policy

	insinto /usr/include/attestation/client
	doins client/dbus_proxy.h
	insinto /usr/include/attestation/common
	doins common/attestation_interface.h
	doins common/print_common_proto.h
	doins common/print_interface_proto.h
	doins "${OUT}"/gen/include/attestation/common/common.pb.h
	doins "${OUT}"/gen/include/attestation/common/interface.pb.h
	insinto /usr/share/protofiles/attestation
	doins common/common.proto
	doins common/interface.proto
}

platform_pkg_test() {
	local tests=(
		attestation_testrunner
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}
