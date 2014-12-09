# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="967591006f5bf86ae7c873e9db07a223bc41acdd"
CROS_WORKON_TREE="dae9ca7462e735e62c1498a3421455bcdb9f23d7"
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
	chromeos-base/libchromeos
	dev-libs/dbus-glib
	"

DEPEND="
	${RDEPEND}
	chromeos-base/system_api
	test? ( dev-cpp/gmock )
	dev-cpp/gtest
	"

src_unpack() {
	platform_src_unpack

	EGIT_REPO_URI="${CROS_GIT_HOST_URL}/chromium/src/components/feedback.git" \
	EGIT_SOURCEDIR="${S}/components/feedback" \
	EGIT_PROJECT="feedback" \
	EGIT_COMMIT="e10399137dacb947741a2a9b092626b9a8dd4a7f" \
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
