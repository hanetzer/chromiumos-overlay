# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="abf933e3f7bc52f8ff080a904c7b17ebbff7053b"
CROS_WORKON_TREE=("61b4b0c05e003fddaa705031945fece7f560c7d7" "b5e2c8a6220353c4c220f3318d9fd66a3410e3e2" "413888b8ea9a5695763b620c5ed048a20960333b" "5a90af94bc390e2a6c512900438034418c8c6b72")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_USE_VCSID=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
# TODO(crbug.com/809389): Avoid directly including headers from other packages.
CROS_WORKON_SUBTREE="common-mk chaps metrics trunks"

PLATFORM_SUBDIR="chaps"

inherit cros-workon platform systemd user

DESCRIPTION="PKCS #11 layer over TrouSerS"
HOMEPAGE="http://www.chromium.org/developers/design-documents/chaps-technical-design"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="systemd test tpm tpm2"

REQUIRED_USE="tpm2? ( !tpm )"

RDEPEND="
	!tpm2? (
		app-crypt/trousers
	)
	tpm2? (
		chromeos-base/trunks
	)
	chromeos-base/minijail
	chromeos-base/libbrillo
	chromeos-base/metrics
	chromeos-base/system_api
	!dev-db/leveldb
	dev-libs/leveldb
	dev-libs/openssl
	dev-libs/protobuf
"

DEPEND="${RDEPEND}
	tpm2? ( chromeos-base/trunks[test?] )
	"

src_install() {
	dosbin "${OUT}"/chapsd
	dobin "${OUT}"/chaps_client
	dobin "${OUT}"/p11_replay
	dolib.so "${OUT}"/lib/libchaps.so

	# Install D-Bus config file.
	dodir /etc/dbus-1/system.d
	sed 's,@POLICY_PERMISSIONS@,group="pkcs11",' \
		"org.chromium.Chaps.conf.in" \
		> "${D}/etc/dbus-1/system.d/org.chromium.Chaps.conf"

	# Install init scripts.
	if use systemd; then
		if use tpm2; then
			sed 's/tcsd.service/trunksd.service' \
				init/chapsd.service \
				> "${T}/chapsd.service"
			systemd_dounit "${T}/chapsd.service"
		else
			systemd_dounit init/chapsd.service
		fi
		systemd_enable_service boot-services.target chapsd.service
		systemd_dotmpfilesd init/chapsd_directories.conf
	else
		insinto /etc/init
		doins init/chapsd.conf
		if use tpm2; then
			sed -i 's/started tcsd/started trunksd/' \
				"${D}/etc/init/chapsd.conf" ||
				die "Can't replace tcsd with trunksd in chapsd.conf"
		fi
	fi
	exeinto /usr/share/cros/init
	doexe init/chapsd.sh

	# Install headers for use by clients.
	insinto /usr/include/chaps
	doins token_manager_client.h
	doins token_manager_client_mock.h
	doins token_manager_interface.h
	doins isolate.h
	doins chaps_proxy_mock.h
	doins chaps_interface.h
	doins chaps.h
	doins attributes.h

	# Install live tests
	if use test; then
		dosbin "${OUT}"/chapsd_test
		dosbin "${OUT}"/tpm_utility_test
	fi

	insinto /usr/include/chaps/pkcs11
	doins pkcs11/*.h
}

platform_pkg_test() {
	local tests=(
		chaps_test
		chaps_service_test
		dbus_test
		slot_manager_test
		session_test
		object_test
		object_policy_test
		object_pool_test
		object_store_test
		opencryptoki_importer_test
		isolate_login_client_test
	)
	use tpm2 && tests+=(
		tpm2_utility_test
	)

	local gtest_filter_qemu=""
	gtest_filter_qemu+="-*DeathTest*"
	gtest_filter_qemu+=":*ImportSample*"
	gtest_filter_qemu+=":TestSession.RSA*"
	gtest_filter_qemu+=":TestSession.KeyTypeMismatch"
	gtest_filter_qemu+=":TestSession.KeyFunctionPermission"
	gtest_filter_qemu+=":TestSession.BadKeySize"
	gtest_filter_qemu+=":TestSession.BadSignature.*"

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}" "" "" "${gtest_filter_qemu}"
	done
}

pkg_preinst() {
	local ug
	for ug in attestation pkcs11 chaps; do
		enewuser "${ug}"
		enewgroup "${ug}"
	done
}
