# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="24159be243aa413116ce4364778840eafc45b1ab"
CROS_WORKON_TREE="1a35571e1d4c0a6409e4ac1eb365c1ce266f47d7"
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
