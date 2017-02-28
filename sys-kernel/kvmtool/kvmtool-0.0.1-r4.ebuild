# Copyright 2017 The Chromium OS Authors.  All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="daab936c1d9ef38dd3ddefc63cb500554deb9369"
CROS_WORKON_TREE="5ae509276fe2459eab65eec0fa9f1be9cd720553"
CROS_WORKON_PROJECT="chromiumos/third_party/kvmtool"
CROS_WORKON_LOCALNAME="kvmtool"

inherit cros-workon

DESCRIPTION="Lightweight tool for running KVM guests"
HOMEPAGE="https://git.kernel.org/cgit/linux/kernel/git/will/kvmtool.git/"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"
IUSE="+aio +zlib"

RDEPEND="
	aio? ( dev-libs/libaio )
	arm? ( sys-apps/dtc )
	zlib? ( sys-libs/zlib )"

DEPEND="${RDEPEND}"

kvm_arch() {
	local arch=${ARCH}
	case ${arch} in
		amd64) arch=x86_64;;
	esac
	echo "${arch}"
}

src_compile() {
	ARCH=$(kvm_arch) emake \
		V=1 \
		CROSS_COMPILE="${CHOST}-" \
		WERROR=0 \
		ARCH_HAS_FRAMEBUFFER=0 \
		USE_AIO="$(usex aio)" \
		USE_ZLIB="$(usex zlib)"
}

src_install() {
	dobin lkvm
}
