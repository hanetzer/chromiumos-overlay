# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT=("7a87834574153f6563c922f38527641eb3daf3f5" "1dddb51900f6aebf3cf6be2a2eab0d60568cf0f2")
CROS_WORKON_TREE=("21832a9f9ecf892665b1d4843a85312f50c70620" "fd746f70ef5f6c90083662b9a39846b6f6a5ce8b")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/aosp/system/tpm")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME=("platform2" "aosp/system/tpm")
CROS_WORKON_PROJECT=("chromiumos/platform2" "aosp/platform/system/tpm")

PLATFORM_SUBDIR="attestation"

inherit cros-workon libchrome platform user

DESCRIPTION="Attestation service for Chromium OS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="tpm tpm2"

REQUIRED_USE="tpm2? ( !tpm )"

RDEPEND="
	tpm? (
		app-crypt/trousers
	)
	tpm2? (
		chromeos-base/trunks
	)
	chromeos-base/chaps
	chromeos-base/chromeos-minijail
	chromeos-base/libbrillo
	chromeos-base/tpm_manager
	"

DEPEND="
	${RDEPEND}
	chromeos-base/vboot_reference
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
	if use tpm2; then
		sed -i 's/started tcsd/started tpm_managerd/' \
			"${D}/etc/init/attestationd.conf" ||
			die "Can't replace tcsd with tpm_managerd in attestationd.conf"
	fi

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
