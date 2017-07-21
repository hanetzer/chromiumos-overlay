# Copyright 2017 The Chromium OS Authors.  All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT=("0ca03501dfd49f8091a04f941c05a71246b24bf4" "62f4aac42436e2a7c7662b95c8ffd726444952b3")
CROS_WORKON_TREE=("798f7e030740ed5db4d4e24660ec634f0329974e" "f59e0ae7b57985127b638aa59a95be8a37478e3d")
CROS_WORKON_PROJECT=("chromiumos/third_party/nfs-ganesha" "chromiumos/third_party/ntirpc")
CROS_WORKON_LOCALNAME=("nfs-ganesha" "ntirpc")
CROS_WORKON_DESTDIR=("${S}" "${S}/src/libntirpc")

inherit user cmake-utils cros-workon

DESCRIPTION="Userspace NFS server"
HOMEPAGE="https://github.com/nfs-ganesha/nfs-ganesha"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="caps rdma test uuid"

RDEPEND="
	app-crypt/mit-krb5
	!net-libs/ntirpc
	net-libs/libnfsidmap
	caps? ( sys-libs/libcap )
	uuid? ( sys-apps/util-linux )
	"

DEPEND="${RDEPEND}
	test? ( dev-cpp/gtest )
	"
RDEPEND+="
	net-nds/rpcbind"

CMAKE_USE_DIR="${S}/src"
# COMPILING_HOWTO says Maintainer is the mode to use for releases.
CMAKE_BUILD_TYPE="Maintainer"

src_configure() {
	local mycmakeargs=(
		-DUSE_SYSTEM_NTIRPC=OFF
		-DUSE_BLKIN=OFF
		-DUSE_LTTNG=OFF
		# nfs-ganesha does not honor the option above in its config
		# -DNTIRPC_BASE_DIR=
		$(cmake-utils_use_use caps LIBCAP)
		$(cmake-utils_use_use rdma RPC_RDMA)
		$(cmake-utils_use_use test GTEST)
		$(cmake-utils_use_use uuid LIBUUID)
	)
	cmake-utils_src_configure
}

src_install() {
	# Install seccomp policy files.
	insinto /usr/share/policy
	newins "${FILESDIR}/nfs-ganesha-seccomp-${ARCH}.policy" nfs-ganesha-seccomp.policy
	cmake-utils_src_install

	# Install the upstart job
	insinto /etc/init
	doins "${FILESDIR}"/nfs-ganesha.conf
}

pkg_preinst() {
	enewuser "ganesha"
	enewgroup "ganesha"
}
