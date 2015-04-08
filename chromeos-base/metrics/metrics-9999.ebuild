# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_USE_VCSID=1
CROS_WORKON_LOCALNAME=("platform2" "../chromium/src/components/metrics")
CROS_WORKON_PROJECT=("chromiumos/platform2" "chromium/src/components/metrics")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/components/metrics")
CROS_WORKON_COMMIT=(master "9f8d4f96900b543e191234c04f182c6de5f9869d")

PLATFORM_SUBDIR="metrics"

# platform.eclass modifies S for the build system. Save the location of the
# probufs now so that we don't have to guess where they are.
PROTO_DIR="${S}/components/metrics/proto/"

inherit cros-constants cros-workon git-2 platform

DESCRIPTION="Metrics aggregation service for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="~*"
IUSE="metrics_uploader +passive_metrics"

RDEPEND="
	chromeos-base/libchromeos
	chromeos-base/system_api
	dev-libs/dbus-glib
	dev-libs/protobuf
	sys-apps/rootdev
	"

DEPEND="
	${RDEPEND}
	chromeos-base/vboot_reference
	test? ( dev-cpp/gmock )
	dev-cpp/gtest
	"

src_install() {
	dobin "${OUT}"/metrics_client syslog_parser.sh

	if use passive_metrics; then
		dobin "${OUT}"/metrics_daemon
		insinto /etc/init
		doins init/metrics_library.conf init/metrics_daemon.conf

		if use metrics_uploader; then
			sed -i '/DAEMON_FLAGS=/s:=.*:="-uploader":' \
				"${D}"/etc/init/metrics_daemon.conf || die
		fi
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

	# Install the protobuf so that autotests can have access to it.
	insinto /usr/include/metrics/proto
	doins "${PROTO_DIR}"/*.proto
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
