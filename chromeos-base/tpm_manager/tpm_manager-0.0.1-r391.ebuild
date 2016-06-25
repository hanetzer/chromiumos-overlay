# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT=("0f16f667487a09a373ef4e3d02db43610e3fb237" "74bf1c9a3a45994780b1d86d2da0015c8f0807e8")
CROS_WORKON_TREE=("7c6f1e7edcd82346482ba7579aef615bafa8d95f" "d0b03d71cb1c8fdc3fd9363474643d1e74d02fc1")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/aosp/system/tpm")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME=("platform2" "aosp/system/tpm")
CROS_WORKON_PROJECT=("chromiumos/platform2" "aosp/platform/system/tpm")
CROS_WORKON_USE_VCSID=1

PLATFORM_SUBDIR="tpm_manager"

inherit cros-workon platform user

DESCRIPTION="Daemon to manage TPM ownership."
HOMEPAGE="http://www.chromium.org/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="test -tpm2"

RDEPEND="
	!tpm2? (
		app-crypt/trousers
	)
	tpm2? (
		chromeos-base/trunks
	)
	chromeos-base/chromeos-minijail
	chromeos-base/libbrillo
	"

DEPEND="
	${RDEPEND}
	test? ( dev-cpp/gmock )
	dev-cpp/gtest
	"

pkg_preinst() {
	enewuser tpm_manager
	enewgroup tpm_manager
}

src_unpack() {
	local s="${S}"
	platform_src_unpack
	S="${s}/aosp/system/tpm/tpm_manager"
}

src_install() {
	# Install D-Bus configuration file.
	insinto /etc/dbus-1/system.d
	doins server/org.chromium.TpmManager.conf

	# Install upstart config file.
	insinto /etc/init
	doins server/tpm_managerd.conf

	# Install the executables provided by TpmManager
	dosbin "${OUT}"/tpm_managerd
	dobin "${OUT}"/tpm_manager_client
	dolib.so "${OUT}"/lib/libtpm_manager.so

	# Install seccomp policy files.
	insinto /usr/share/policy
	newins server/tpm_manager-seccomp-${ARCH}.policy tpm_managerd-seccomp.policy

	# Install header files.
	insinto /usr/include/tpm_manager/tpm_manager_client
	doins client/tpm_nvram_dbus_proxy.h
	doins client/tpm_ownership_dbus_proxy.h
	insinto /usr/include/tpm_manager/common
	doins common/export.h
	doins common/tpm_manager_constants.h
	doins common/tpm_nvram_interface.h
	doins common/tpm_ownership_interface.h
}

platform_pkg_test() {
	local tests=(
		tpm_manager_testrunner
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}
