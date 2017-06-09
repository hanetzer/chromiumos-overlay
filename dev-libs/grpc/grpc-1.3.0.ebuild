# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

PYTHON_COMPAT=( python2_7 python3_{4,5} )
inherit python-r1 toolchain-funcs multilib

DESCRIPTION="Modern open source high performance RPC framework"
HOMEPAGE="http://www.grpc.io"
SRC_URI="https://github.com/grpc/grpc/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	>=dev-libs/openssl-1.0.2
	>=dev-libs/protobuf-3:=
	net-dns/c-ares
	sys-libs/zlib"

DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}/0001-${P}-Fix-incorrect-sonames-and-library-path.patch"
	"${FILESDIR}/0002-${P}-Fix-cross-compiling.patch"
	"${FILESDIR}/0003-${P}-Fix-unsecure-.pc-files.patch"
	"${FILESDIR}/0004-${P}-Support-vsock.patch"
	"${FILESDIR}/0005-${P}-Don-t-run-ldconfig.patch"
)

src_prepare() {
	epatch "${PATCHES[@]}"
}

src_compile() {
	tc-export CC CXX PKG_CONFIG
	emake \
		V=1 \
		prefix=/usr \
		AR="$(tc-getAR)" \
		AROPTS="rcs" \
		LD="${CC}" \
		LDXX="${CXX}" \
		STRIP=true \
		HOST_CC="$(tc-getBUILD_CC)" \
		HOST_CXX="$(tc-getBUILD_CXX)" \
		HOST_LD="$(tc-getBUILD_CC)" \
		HOST_LDXX="$(tc-getBUILD_CXX)" \
		HOST_AR="$(tc-getBUILD_AR)"
}

src_install() {
	emake \
		prefix="${D}"/usr \
		INSTALL_LIBDIR="$(get_libdir)" \
		install
}
