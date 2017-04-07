# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="67f5eb35b74ae42d63387cdc6d35f5c2e3fc688b"
CROS_WORKON_TREE="a7c7538649be6d3a093126d7f7b794358733b766"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_USE_VCSID=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"

PLATFORM_SUBDIR="feedback"

inherit cros-constants cros-workon git-2 platform

DESCRIPTION="Feedback service for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	chromeos-base/libbrillo
	"

DEPEND="
	${RDEPEND}
	chromeos-base/system_api
	dev-cpp/gtest
	"

src_unpack() {
	platform_src_unpack

	EGIT_REPO_URI="${CROS_GIT_HOST_URL}/chromium/src/components/feedback.git" \
	EGIT_SOURCEDIR="${S}/components/feedback" \
	EGIT_PROJECT="feedback" \
	EGIT_COMMIT="fe1dc2b6d694d240e0417cd9673220ca6989edc1" \
	git-2_src_unpack
}

src_install() {
	dobin "${OUT}"/feedback_client
	dobin "${OUT}"/feedback_daemon

	insinto /etc/init
	doins init/feedback_daemon.conf

	insinto /etc/dbus-1/system.d
	doins org.chromium.feedback.conf

	insinto /usr/include/feedback
	doins components/feedback/feedback_common.h
	doins feedback_service_interface.h
}

platform_pkg_test() {
	local tests=(
		feedback_daemon_test
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}
