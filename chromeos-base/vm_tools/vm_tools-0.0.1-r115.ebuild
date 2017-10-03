# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="7334feb3e2c5aab69ac1dd9a03e24b9e6caf91e9"
CROS_WORKON_TREE="453e4cdbe70db7ea3856f5682ef63ff823b32525"
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
		dobin "${OUT}"/vm_launcher
		dobin "${OUT}"/vmlog_forwarder
	else
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
