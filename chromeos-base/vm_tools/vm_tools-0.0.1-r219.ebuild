# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="f5ed93fdcc95af8043c4117b6cdee110e9706f35"
CROS_WORKON_TREE="4b29a126ea37dd86c627dfc4052aea1e2dcf4587"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_INCREMENTAL_BUILD=1

PLATFORM_SUBDIR="vm_tools"

inherit cros-workon platform user

DESCRIPTION="VM orchestration tools for Chrome OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/vm_tools"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="kvm_host"

RDEPEND="
	chromeos-base/minijail
	dev-libs/grpc
	dev-libs/protobuf:=
	kvm_host? ( chromeos-base/libbrillo )
	!kvm_host? ( !!sys-apps/upstart )
"
DEPEND="${RDEPEND}"

src_install() {
	if use kvm_host; then
		dobin "${OUT}"/maitred_client
		dobin "${OUT}"/vm_launcher
		dobin "${OUT}"/vmlog_forwarder
	else
		dobin "${OUT}"/virtwl_guest_proxy
		dobin "${OUT}"/vm_syslog

		into /
		newsbin "${OUT}"/maitred init
	fi
}

platform_pkg_test() {
	local tests=()

	if use kvm_host; then
		tests+=(
			syslog_forwarder_test
		)
	else
		tests+=(
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
	if ! use kvm_host; then
		enewuser syslog
		enewgroup syslog
	fi
}
