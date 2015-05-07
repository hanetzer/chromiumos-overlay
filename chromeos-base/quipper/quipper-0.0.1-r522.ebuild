# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="a53573ae32ca50c9df56d96e42564962ba0a5fdc"
CROS_WORKON_TREE="1c1dddef178677f5a25da1deb26610278193ef13"
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
		perf_parser_test
		perf_reader_test
		perf_recorder_test
		perf_serializer_test
		run_command_test
		scoped_temp_path_test
		utils_test
	)
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}" "1"
	done
}
