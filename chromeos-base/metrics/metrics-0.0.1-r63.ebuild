# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="ff17ff06a649690f230cd8fcf6181defede8703e"
CROS_WORKON_TREE="8c3bf75cc00eb9fe2063a6c369eef724624b6006"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_USE_VCSID=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"

PLATFORM_SUBDIR="metrics"

inherit cros-constants cros-workon git-2 platform

DESCRIPTION="Metrics aggregation service for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="+passive_metrics"

RDEPEND="
	chromeos-base/libchromeos
	!<chromeos-base/platform2-0.0.4
	chromeos-base/system_api
	>=dev-cpp/gflags-2.0
	dev-libs/dbus-glib
	sys-apps/rootdev
	"

DEPEND="
	${RDEPEND}
	chromeos-base/vboot_reference
	test? ( dev-cpp/gmock )
	dev-cpp/gtest
	"

src_unpack() {
	platform_src_unpack

	EGIT_REPO_URI="${CROS_GIT_HOST_URL}/chromium/src/components/metrics.git" \
	EGIT_SOURCEDIR="${S}/components/metrics" \
	EGIT_PROJECT="metrics" \
	EGIT_COMMIT="98a769a9a70b2ff0dbcf4962c5d79b29a60c8860" \
	git-2_src_unpack
}

src_install() {
	dobin "${OUT}"/metrics_client syslog_parser.sh

	if use passive_metrics; then
		dobin "${OUT}"/metrics_daemon
		insinto /etc/init
		doins init/metrics_library.conf
		doins init/metrics_daemon.conf
	fi

	insinto /usr/$(get_libdir)/pkgconfig
	for v in "${LIBCHROME_VERS[@]}"; do
		./platform2_preinstall.sh "${OUT}" "${v}"
		dolib.so "${OUT}/lib/libmetrics-${v}.so"
		doins "${OUT}/lib/libmetrics-${v}.pc"
	done

	insinto /usr/include/metrics
	doins c_metrics_library.h \
		metrics_library{,_mock}.h \
		timer{,_mock}.h
}

platform_pkg_test() {
	local tests=(
		metrics_library_test
		$(usex passive_metrics 'metrics_daemon_test' '')
                persistent_integer_test
		timer_test
		upload_service_test
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}
