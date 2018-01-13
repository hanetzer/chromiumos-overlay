# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="740fe7a12e78c44d85e2181bcbac04256f5f9e38"
CROS_WORKON_TREE="ffa4888850cc1fc33dd56ac17dab3f73a1999101"
CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_NATIVE_TEST="yes"
PLATFORM_SUBDIR="arc/setup"
PLATFORM_GYP_FILE="arc-setup.gyp"

inherit cros-workon platform

DESCRIPTION="Set up environment to run ARC."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/arc/setup"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="
	android-container-master-arc-dev
	cheets_aosp_userdebug
	cheets_aosp_userdebug_64
	houdini
	ndk_translation"

RDEPEND="
	!<chromeos-base/chromeos-cheets-scripts-0.0.2
	chromeos-base/cryptohome-client
	chromeos-base/libbrillo
	chromeos-base/metrics
	chromeos-base/minijail
	sys-libs/libselinux
	dev-libs/protobuf"

DEPEND="${RDEPEND}
	chromeos-base/system_api"

src_install() {
	dosbin "${OUT}"/arc-setup
}

platform_pkg_test() {
	platform_test "run" "${OUT}/arc-setup_testrunner"
}
