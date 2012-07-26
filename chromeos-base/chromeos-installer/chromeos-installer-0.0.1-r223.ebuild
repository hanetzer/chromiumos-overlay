# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="f55871f3db490df1c89d708a11798c3595381837"
CROS_WORKON_TREE="210452ea179b9b6fe2012fa063313243dbe99893"

EAPI="4"
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
	chromeos-base/verity
	!cros_host? (
		chromeos-base/vboot_reference
	)"

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
	# We don't need the installer in the sdk, just helper scripts.
	use cros_host && return 0

	# need this to get the verity headers working
	append-cxxflags -I"${SYSROOT}"/usr/include/verity/

	use 32bit_au && board_setup_32bit_au_env

	tc-export AR CC CXX OBJCOPY
	cros-debug-add-NDEBUG
	# Disable split debug and stripping (since portage does this).
	emake \
		OUT="${S}/build" \
		SPLITDEBUG=0 STRIP=true \
		cros_installer
}


src_test() {
	emake tests
}

src_install() {
	local path
	if use cros_host ; then
		# Copy chromeos-* scripts to /usr/lib/installer/ on host.
		path="usr/lib/installer"
	else
		path="usr/sbin"
		dobin build/cros_installer
		dosym ${path}/chromeos-postinst /postinst
	fi

	exeinto /${path}
	doexe chromeos-*
}
