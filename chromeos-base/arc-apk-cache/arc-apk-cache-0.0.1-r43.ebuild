# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="95f3e2de6095c149434b856b5607dea9c9130f7c"
CROS_WORKON_TREE="a89880ac158cdfd869f2bd1ae9e9f24422c25751"
CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_NATIVE_TEST="yes"
PLATFORM_SUBDIR="arc/apk-cache"
PLATFORM_GYP_FILE="apk-cache.gyp"

inherit cros-workon platform

DESCRIPTION="Maintains APK cache in ARC."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/arc/apk-cache"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="+seccomp"

RDEPEND="
	chromeos-base/minijail"

DEPEND="${RDEPEND}"

src_install() {
	insinto /etc/init
	doins init/apk-cache-cleaner.conf

	# Install seccomp policy file.
	insinto /usr/share/policy
	use seccomp && newins \
		"seccomp/apk-cache-cleaner-seccomp-${ARCH}.policy" \
		apk-cache-cleaner-seccomp.policy

	dosbin "${OUT}/apk-cache-cleaner"
	dosbin apk-cache-cleaner-jailed
}

platform_pkg_test() {
	platform_test "run" "${OUT}/apk-cache-cleaner_testrunner"
}
