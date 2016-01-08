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
	# Create group for /mnt/stateful_partition/unencrypted/preserve.
	enewgroup "preserve"
}

src_unpack() {
	local s="${S}"
	platform_src_unpack
	S="${s}/aosp/system/tpm/attestation"
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
