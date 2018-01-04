# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="cd464c4251f7e60526ed167f1828e07295eff9fe"
CROS_WORKON_TREE="7007a40e5169344fbb2809fbbd6c0ac76e151fa8"
CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="libcontainer"

inherit cros-workon platform user

DESCRIPTION="Library to run jailed containers on Chrome OS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="+device-mapper"

# Need lvm2 for devmapper.
RDEPEND="chromeos-base/minijail
	device-mapper? ( sys-fs/lvm2 )"
DEPEND="${RDEPEND}
	chromeos-base/libbrillo"

src_install() {
	into /
	dolib.so "${OUT}"/lib/libcontainer.so

	"${S}"/platform2_preinstall.sh "${PV}" "/usr/include/chromeos" "${OUT}"
	insinto "/usr/$(get_libdir)/pkgconfig"
	doins "${OUT}"/libcontainer.pc

	insinto "/usr/include/chromeos"
	doins libcontainer.h
}

platform_pkg_test() {
	platform_test "run" "${OUT}"/libcontainer_test
}
