# Copyright 2017 The Chromium OS Authors.  All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="6150fc9128a10211decdb44bf42ac8a04f699a64"
CROS_WORKON_TREE="d29be48ff3db8790dd137230a89731e7aa4db846"
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
