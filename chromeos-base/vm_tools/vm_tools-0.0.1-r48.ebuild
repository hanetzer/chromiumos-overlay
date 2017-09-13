# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="8e7f18229f3402bc6c85712a73bd2c65b46d7bb3"
CROS_WORKON_TREE="36647bf97bf8a497227c9cd8e1e4ce282dcc6925"
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
	chromeos-base/chromeos-minijail
	dev-libs/grpc
	dev-libs/protobuf:=
	kvm_host? ( chromeos-base/libbrillo )
	!kvm_host? ( !!sys-apps/upstart )
"
DEPEND="${RDEPEND}"

src_install() {
	if use kvm_host; then
		dobin "${OUT}"/maitred_client
	else
		dobin "${OUT}"/vm_syslog

		into /
		newsbin "${OUT}"/maitred init
	fi
}

platform_pkg_test() {
	local tests=(
		maitred_service_test
		maitred_syslog_test
	)

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
