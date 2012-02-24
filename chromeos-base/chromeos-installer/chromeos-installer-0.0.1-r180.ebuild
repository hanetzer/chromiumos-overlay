# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="f597e3c0a90b84c3ec0fd3c4b59e7d0e83e3c7b9"
CROS_WORKON_PROJECT="chromiumos/platform/installer"
CROS_WORKON_LOCALNAME="installer"

inherit cros-workon cros-debug cros-au

DESCRIPTION="Chrome OS Installer"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="32bit_au cros_host"

DEPEND="
	chromeos-base/libchrome:0[cros-debug=]
	chromeos-base/vboot_reference
	sys-libs/libbb"

# TODO(adlr): remove coreutils dep if we move to busybox
RDEPEND="
	app-admin/sudo
	chromeos-base/vboot_reference
	chromeos-base/vpd
	dev-util/shflags
	sys-apps/coreutils
	sys-apps/flashrom
	sys-apps/hdparm
	sys-apps/rootdev
	sys-apps/util-linux
	sys-apps/which
	sys-fs/dosfstools
	sys-fs/e2fsprogs"

src_compile() {
	use 32bit_au && board_setup_32bit_au_env

	tc-export AR CC CXX OBJCOPY
	cros-debug-add-NDEBUG
	# Disable split debug and stripping (since portage does this).
	emake \
		OUT="${S}/build" \
		SPLITDEBUG=0 STRIP=true \
		cros_installer
}

src_install() {
	local path
	if ! use cros_host; then
		path="usr/sbin"
	else
		# Copy chromeos-* scripts to /usr/lib/installer/ on host.
		path="usr/lib/installer"
	fi

	exeinto /${path}
	dosym ${path}/chromeos-postinst /postinst
	doexe chromeos-*
	dobin build/cros_installer
}
