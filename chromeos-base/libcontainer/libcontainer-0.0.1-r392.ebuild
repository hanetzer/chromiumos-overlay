# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="f8ca532441badb955e0e39c1cb02c9810af31145"
CROS_WORKON_TREE="61c17c32a6741e65c27df169709a7e4b96304773"
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
RDEPEND="chromeos-base/chromeos-minijail
	device-mapper? ( sys-fs/lvm2 )"
DEPEND="${RDEPEND}"

src_install() {
	into /
	dolib.so "${OUT}"/lib/libcontainer.so

	"${S}"/platform2_preinstall.sh "${PV}" "/usr/include/chromeos" "${OUT}"
	insinto "/usr/$(get_libdir)/pkgconfig"
	doins "${OUT}"/libcontainer.pc

	insinto "/usr/include/chromeos"
	doins libcontainer.h
}

src_test() {
	platform_test "run" "${OUT}"/container_cgroup_unittest
}
