# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="adf4844e956e653e0ec2b0e7baeb0faf0727d2e7"
CROS_WORKON_TREE=("61b4b0c05e003fddaa705031945fece7f560c7d7" "0daf57074ff668564ceeb4acc0a292b210e622a8")
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
