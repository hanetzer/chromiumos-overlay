# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="6ae036323b3655d57e88723b9a637e16483a20c1"
CROS_WORKON_TREE=("99d4f98c0151c7e25437bb625f114bde347170d5" "4ab3baedc8680b25e7ef4a4db5ef3a5dae903b37")
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_SUBTREE="common-mk vm_tools"

PLATFORM_SUBDIR="vm_tools"

inherit cros-workon platform udev user

DESCRIPTION="VM orchestration tools for Chrome OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/vm_tools"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="kvm_host"

RDEPEND="
	chromeos-base/libbrillo
	chromeos-base/minijail
	dev-libs/grpc
	dev-libs/protobuf:=
	kvm_host? ( chromeos-base/crosvm )
	!kvm_host? ( !!sys-apps/upstart )
"
DEPEND="
	${RDEPEND}
	kvm_host? ( >=chromeos-base/system_api-0.0.1-r3259 )
	!kvm_host? ( >=sys-kernel/linux-headers-4.4-r10 )
"

src_install() {
	if use kvm_host; then
		dobin "${OUT}"/maitred_client
		dobin "${OUT}"/vmlog_forwarder
		dobin "${OUT}"/vsh
		dobin "${OUT}"/vm_concierge
		dobin "${OUT}"/concierge_client

		insinto /etc/init
		doins init/*.conf

		insinto /etc/dbus-1/system.d
		doins dbus/org.chromium.VmConcierge.conf

		udev_dorules udev/99-vm.rules
	else
		dobin "${OUT}"/virtwl_guest_proxy
		dobin "${OUT}"/vm_syslog
		dobin "${OUT}"/garcon
		dosbin "${OUT}"/vshd

		into /
		newsbin "${OUT}"/maitred init
	fi
}

platform_pkg_test() {
	local tests=()

	if use kvm_host; then
		tests+=(
			concierge_test
			syslog_forwarder_test
		)
	else
		tests+=(
			garcon_desktop_file_test
			maitred_service_test
			maitred_syslog_test
		)
	fi

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}

pkg_preinst() {
	# We need the syslog user and group for both host and guest builds.
	enewuser syslog
	enewgroup syslog
}
