# Copyright 2017 The Chromium OS Authors.  All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_PROJECT="chromiumos/third_party/nfs-ganesha"
CROS_WORKON_LOCALNAME="nfs-ganesha"

inherit cmake-utils cros-workon

DESCRIPTION="Userspace NFS server"
HOMEPAGE="https://github.com/nfs-ganesha/nfs-ganesha"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~*"
IUSE="caps rdma test uuid"

RDEPEND="
	caps? ( sys-libs/libcap )
	net-libs/ntirpc:=
	uuid? ( sys-apps/util-linux )
	"

DEPEND="${RDEPEND}
	test? ( dev-cpp/gtest )
	"

CMAKE_USE_DIR="${S}/src"
# COMPILING_HOWTO says Maintainer is the mode to use for releases.
CMAKE_BUILD_TYPE="Maintainer"

src_configure() {
	local mycmakeargs=(
		-DUSE_SYSTEM_NTIRPC=ON
		-DUSE_BLKIN=OFF
		-DUSE_LTTNG=OFF
		$(cmake-utils_use_use caps LIBCAP)
		$(cmake-utils_use_use rdma RPC_RDMA)
		$(cmake-utils_use_use test GTEST)
		$(cmake-utils_use_use uuid LIBUUID)
	)
	cmake-utils_src_configure
}
