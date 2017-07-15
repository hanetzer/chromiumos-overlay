# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="0436e7b17d2b1d1f91983c815de5c5f921569654"
CROS_WORKON_TREE="0cefd6de61a79660d4660bb2ae92e8b44b351a19"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

inherit arc-build autotest cros-workon flag-o-matic

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

src_configure() {
	# Use arc-build base class to select the right compiler for native Android code.
	arc-build-select-gcc

	# The ARC sysroot only has prebuilt 32-bit libraries at this point
	case ${ARCH} in
	arm)
		# Nothing to do in this case
		;;
	amd64)
		append-flags -m32
		append-ldflags -m32
		;;
	esac
}
