# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="31e28be5ddbd13c7abee26f6786a437525e31d85"
CROS_WORKON_TREE="4d5eb638b6d3cba1a62fca5a293fa23a24c82a0f"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_USE_VCSID=1

CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"

PLATFORM_SUBDIR="chromiumos-wide-profiling"

inherit cros-workon platform

DESCRIPTION="quipper: chromiumos wide profiling"
HOMEPAGE="http://www.chromium.org/chromium-os/profiling-in-chromeos"
TEST_DATA_SOURCE="quipper-20150417.tar.gz"
SRC_URI="gs://chromeos-localmirror/distfiles/${TEST_DATA_SOURCE}"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="
	>=dev-libs/glib-2.30
	dev-util/perf
"

DEPEND="${RDEPEND}
	chromeos-base/protofiles
	test? (
		app-shells/dash
		dev-cpp/gmock
	)
	dev-cpp/gtest
"

src_unpack() {
	platform_src_unpack

	pushd "${S}" >/dev/null
	unpack ${TEST_DATA_SOURCE}
	popd >/dev/null
}

src_install() {
	dobin "${OUT}"/quipper
}

platform_pkg_test() {
	local tests=(
		address_mapper_test
		buffer_reader_test
		buffer_writer_test
		run_command_test
		scoped_temp_path_test
		utils_test
	)
	# These tests don't work quite right when there is a mismatch between
	# the active running kernel and the test target (bitwise).
	# Also, below tests are temporarily disabled, see crbug.com/340543
	use amd64 && tests+=(
		perf_parser_test
		perf_reader_test
		perf_recorder_test
		perf_serializer_test
	)
	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}" "1"
	done
}
