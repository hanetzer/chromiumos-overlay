# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT="2f0f4cd8c27692693b4963e8d50dc3424bc8d9e8"
CROS_WORKON_TREE="d69e8a357cdf1860cb87a41642597d6cc290bce5"
CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="arc/obb-mounter"
PLATFORM_GYP_FILE="obb-mounter.gyp"

inherit cros-workon platform

DESCRIPTION="D-Bus service to mount OBB files"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/arc/obb-mounter"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	chromeos-base/libbrillo
	sys-fs/fuse
	sys-libs/libcap
"

DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_install() {
	dobin "${OUT}"/arc-obb-mounter
	dobin "${OUT}"/mount-obb

	insinto /etc/dbus-1/system.d
	doins org.chromium.ArcObbMounter.conf
}

platform_pkg_test() {
	platform_test "run" "${OUT}/arc-obb-mounter_testrunner"
}
