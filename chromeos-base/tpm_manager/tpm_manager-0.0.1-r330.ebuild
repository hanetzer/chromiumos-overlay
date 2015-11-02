# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT=("964d08ddbc222c92f3e9a6602674fa6f5dfbfdfe" "3d4bda022ae92db15a5b28ad9b22b8cede3fa7ea")
CROS_WORKON_TREE=("07fa74ea3315dc19ed48318b00d8b5ffcc352f3b" "f78439af539e946cc8fca3e1cd0b2c75bca624b0")
CROS_WORKON_BLACKLIST=1
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/aosp/system/tpm_manager")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME=("platform2" "aosp/system/tpm_manager")
CROS_WORKON_PROJECT=("chromiumos/platform2" "platform/system/tpm_manager")
CROS_WORKON_REPO=("https://chromium.googlesource.com" "https://android.googlesource.com")
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
	S="${s}/aosp/system/tpm_manager"
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
