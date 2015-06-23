# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="4968830b913f845d3b6edd110c8f5e9bfe86f798"
CROS_WORKON_TREE="a9b49ecbdbdac080be258949a254ef10c89dfa93"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_USE_VCSID=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="tpm_manager"

inherit cros-workon platform user

DESCRIPTION="Daemon to manage TPM ownership."
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="
	chromeos-base/chromeos-minijail
	chromeos-base/libchromeos
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
	doins client/dbus_proxy.h
	insinto /usr/include/tpm_manager/common
	doins common/export.h
	doins common/tpm_manager_interface.h
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
