# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="575e8f1ad46ee941bf1c66ce3cd8d4d874a55bee"
CROS_WORKON_TREE="056451879521e51a66e029fd40ee00a4d210c342"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

inherit autotest cros-workon flag-o-matic

DESCRIPTION="Public ARC autotests"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

CLIENT_TESTS="
	+tests_cheets_StartAndroid
	+tests_graphics_Gralloc
"

IUSE_TESTS="${CLIENT_TESTS}"

RDEPEND="
	dev-python/pyxattr
	chromeos-base/chromeos-chrome
	chromeos-base/autotest-chrome
	chromeos-base/telemetry
	"

DEPEND="${RDEPEND}"

IUSE="
	+autotest
	${IUSE_TESTS}
"

src_prepare() {
	# Telemetry tests require the path to telemetry source to exist in order to
	# build. Copy the telemetry source to a temporary directory that is writable,
	# so that file removals in Telemetry source can be performed properly.
	export TMP_DIR="$(mktemp -d)"
	cp -r "${SYSROOT}/usr/local/telemetry" "${TMP_DIR}"
	export PYTHONPATH="${TMP_DIR}/telemetry/src/third_party/catapult/telemetry"
	autotest_src_prepare
}