# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="57ac7b0dd771f31db0c542743fd34e6d4d22b4af"
CROS_WORKON_TREE="cae0e053d6e37f16d9bf680e2c9fc4953cd8e2d8"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"

PLATFORM_SUBDIR="bootstat"

inherit cros-workon platform

DESCRIPTION="Chrome OS Boot Time Statistics Utilities"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	sys-apps/rootdev
	"
DEPEND="${RDEPEND}
	chromeos-base/libbrillo
"

src_install() {
	dosbin "${OUT}"/bootstat
	dosbin bootstat_archive
	dosbin bootstat_get_last
	dobin bootstat_summary

	dolib.so "${OUT}"/lib/libbootstat.so

	insinto /usr/include/metrics
	doins bootstat.h
}

platform_pkg_test() {
	platform_test "run" "${OUT}/libbootstat_unittests"
}
