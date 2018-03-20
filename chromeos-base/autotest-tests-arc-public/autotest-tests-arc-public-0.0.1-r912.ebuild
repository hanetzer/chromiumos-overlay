# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="cd229530ed52ff5688ea207088596d5d784fd961"
CROS_WORKON_TREE="5dc95497e475388c2712e3c6c687199163484b90"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest/files

inherit autotest cros-workon flag-o-matic

DESCRIPTION="Public ARC autotests"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

CLIENT_TESTS="
	android-container-nyc? (
		+tests_cheets_Midis
		+tests_cheets_StartAndroid
	)
	android-container-master-arc-dev? (
		+tests_cheets_Midis_P
		+tests_cheets_StartAndroid_P
	)
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
	android-container-nyc
	android-container-master-arc-dev
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
