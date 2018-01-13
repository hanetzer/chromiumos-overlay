# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="2f02ab8283db2221e3c57f943bfe89f6be8d718e"
CROS_WORKON_TREE="f8ee04fb074e30542c8745dad511605afd83038b"
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
