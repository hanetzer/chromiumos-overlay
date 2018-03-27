# Copyright 2017 The Chromium OS Authors.  All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="1b159b990afd33c0c2e3b47ebda6dd5cc793dd92"
CROS_WORKON_TREE="0c970049ad35f82608564636801a08410e7da16b"
CROS_WORKON_PROJECT="chromiumos/third_party/kvmtool"
CROS_WORKON_LOCALNAME="kvmtool"

inherit cros-workon

DESCRIPTION="Lightweight tool for running KVM guests"
HOMEPAGE="https://git.kernel.org/cgit/linux/kernel/git/will/kvmtool.git/"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"
IUSE="+aio +zlib static"

LIB_DEPEND="
	aio? ( dev-libs/libaio[static-libs(+)] )
	arm? ( sys-apps/dtc[static-libs(+)] )
	zlib? ( sys-libs/zlib[static-libs(+)] )"
RDEPEND="!static? ( ${LIB_DEPEND//\[static-libs(+)]} )"
DEPEND="${RDEPEND}
	static? ( ${LIB_DEPEND} )"

src_configure() {
	TARGET="lkvm"
	if use static ; then
		TARGET="${TARGET}-static"
	fi
}

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
		USE_ZLIB="$(usex zlib)" \
		"${TARGET}"
}

src_install() {
	newbin "${TARGET}" lkvm
}
