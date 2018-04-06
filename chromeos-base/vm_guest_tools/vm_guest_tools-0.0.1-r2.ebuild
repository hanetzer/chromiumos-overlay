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

inherit cros-workon platform user

DESCRIPTION="VM guest tools for Chrome OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/vm_tools"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	!!chromeos-base/vm_tools
	chromeos-base/libbrillo
	chromeos-base/minijail
	dev-libs/grpc
	dev-libs/protobuf:=
"
DEPEND="
	${RDEPEND}
	>=sys-kernel/linux-headers-4.4-r10
"

src_install() {
	dobin "${OUT}"/virtwl_guest_proxy
	dobin "${OUT}"/vm_syslog
	dobin "${OUT}"/garcon
	dosbin "${OUT}"/vshd

	into /
	newsbin "${OUT}"/maitred init
}

platform_pkg_test() {
	local tests=(
		garcon_desktop_file_test
		maitred_service_test
		maitred_syslog_test
	)

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
