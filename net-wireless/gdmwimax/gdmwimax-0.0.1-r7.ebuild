# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="827c09994dd166a035a5431d496a61c2e6007d11"
CROS_WORKON_TREE="723cd64b46e284897b5610524636d8423b623ab5"

EAPI=4
CROS_WORKON_PROJECT="chromiumos/third_party/gdmwimax"

inherit cros-workon

DESCRIPTION="GCT GDM7205 WiMAX SDK"
HOMEPAGE="http://www.gctsemi.com/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

src_prepare() {
	# Create build configuration file.
	cat > .config <<-EOF
		CONFIG_DM_INTERFACE=y
		CONFIG_DM_NET_DEVICE=eth0
		CONFIG_LOG_FILE_BUF_SIZE=0x80000
		CONFIG_ENABLE_BW_SWITCHING_FOR_KT=n
		CONFIG_ENABLE_SERVICE_FLOW=n
		CONFIG_WIMAX2=n
	EOF
}

src_compile() {
	tc-export AR CC
	emake -C sdk
	emake -C cm
}

src_install() {
	# Install SDK library.
	dolib sdk/libgdmwimax.a

	# Install SDK headers.
	insinto /usr/include/gct
	doins sdk/{gctapi.h,gcttype.h,WiMaxType.h}

	# Install connection manager executable and configuration file.
	exeinto /opt/gct
	doexe cm/cm
	insinto /opt/gct
	doins cm/cm.conf

	# Install firmware.
	insinto /lib/firmware/gdm72xx
	doins firmware/gdmuimg.bin
}
