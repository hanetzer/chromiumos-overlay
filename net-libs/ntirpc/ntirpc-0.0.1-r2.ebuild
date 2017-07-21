# Copyright 2017 The Chromium OS Authors.  All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="62f4aac42436e2a7c7662b95c8ffd726444952b3"
CROS_WORKON_TREE="f59e0ae7b57985127b638aa59a95be8a37478e3d"
CROS_WORKON_PROJECT="chromiumos/third_party/ntirpc"
CROS_WORKON_LOCALNAME="ntirpc"

inherit cmake-multilib cros-workon

DESCRIPTION="Transport Independent RPC library for nfs-ganesha"
HOMEPAGE="https://github.com/nfs-ganesha/ntirpc"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="gssapi rdma"

RDEPEND="
	app-crypt/mit-krb5
	rdma? ( sys-fabric/libdrmacm )
	"

DEPEND="${RDEPEND}"

multilib_src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use_use gssapi GSS)
		$(cmake-utils_use_use rdma RPC_RDMA)
	)
	cmake-utils_src_configure
}
