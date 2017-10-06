# Copyright 2017 The Chromium OS Authors.  All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="a9fc54d636fc3e5b5f0918769a2e5343c5f0d823"
CROS_WORKON_TREE="88d265872a677ae108eaa4cfea94602341b7a51f"
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
