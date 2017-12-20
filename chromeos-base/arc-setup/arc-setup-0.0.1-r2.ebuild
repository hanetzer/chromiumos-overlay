# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="5f147ea1bcc7f001d4e385c196e81236492da291"
CROS_WORKON_TREE="815dc2db144da7d69355cef6011f8ae3a5ed72f8"
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
