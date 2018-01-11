# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="61a1e84dc05eae91d18bbddc9a58a512daf9e4f7"
CROS_WORKON_TREE="2aa690c19a4a969ab006cc29e618f392ea909e8e"
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
