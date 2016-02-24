# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="68af63fda17416fdeb77de25a3517d8c2d9438ce"
CROS_WORKON_TREE="28798b40ad5c66be382dd1e3b61982d6a4e9be3d"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

inherit cros-workon autotest

DESCRIPTION="Autotest server tests for shill"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

# Enable autotest by default.
IUSE="+autotest"

RDEPEND=""
DEPEND="${RDEPEND}
	!<chromeos-base/autotest-server-tests-0.0.2
"

SERVER_IUSE_TESTS="
	+tests_telemetry_AFDOGenerate
	+tests_telemetry_Benchmarks
	+tests_telemetry_Crosperf
	+tests_telemetry_CrosTests
	+tests_telemetry_GpuTests
"

IUSE_TESTS="${IUSE_TESTS}
	${SERVER_IUSE_TESTS}
"

IUSE="${IUSE} ${IUSE_TESTS}"

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"
