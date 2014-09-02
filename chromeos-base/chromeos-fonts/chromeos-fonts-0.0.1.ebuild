# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

DESCRIPTION="Chrome OS Fonts (meta package)"
HOMEPAGE="http://src.chromium.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="cros_host internal"

# Internal and external builds deliver different fonts for Japanese.
# Although the two fonts can in theory co-exist, the font selection
# code in the chromeos-initramfs build prefers one or the other, but
# not both.
#
# The build system will actually try to make both fonts co-exist in
# some cases, because the default chroot downloaded by cros_sdk
# includes the ja-ipafonts package.  The logic here also protects
# in the case that you switch a repo from internal to external, and
# vice-versa.
JA_FONTS="
	internal? (
		chromeos-base/ja-motoyafonts
		!media-fonts/ja-ipafonts
	)
	!internal? (
		!chromeos-base/ja-motoyafonts
		media-fonts/ja-ipafonts
	)
	"

# List of font packages used in Chromium OS.  This list is separate
# so that it can be shared between the host in
# chromeos-base/hard-host-depends and the target in
# chromeos-base/chromeos.
#
# The glibc requirement is a bit funky.  For target boards, we make sure it is
# installed before any other package (by way of setup_board), but for the sdk
# board, we don't have that toolchain-specific tweak.  So we end up installing
# these in parallel and the chroot logic for font generation fails.  We can
# drop this when we stop executing the helper in the $ROOT via `chroot` and/or
# `qemu` (e.g. when we do `ROOT=/build/amd64-host/ emerge chromeos-fonts`).
#
# The gcc-libs requirement is a similar situation.  Ultimately this comes down
# to fixing http://crbug.com/205424.
RDEPEND="
	${JA_FONTS}
	internal? ( chromeos-base/ascender_to_license )
	media-fonts/croscorefonts
	media-fonts/crosextrafonts
	media-fonts/crosextrafonts-carlito
	media-fonts/noto-cjk
	media-fonts/notofonts
	media-fonts/dejavu
	media-fonts/droidfonts-cros
	media-fonts/ko-nanumfonts
	media-fonts/lohitfonts-cros
	media-fonts/ml-anjalioldlipi
	media-fonts/my-padauk
	media-fonts/robotofonts
	media-fonts/sil-abyssinica
	media-fonts/tibt-jomolhari
	media-libs/fontconfig
	!cros_host? ( sys-libs/gcc-libs )
	cros_host? ( sys-libs/glibc )
	"

generate_font_cache() {
	mkdir -p "${ROOT}/usr/share/fontconfig" || die
	# Change to a simple location as we don't need the CWD to be propagated
	# into the sysroot (as it might not exist).
	cd /
	# fc-cache needs the font files to be located in their final resting place.
	/mnt/host/source/src/platform2/common-mk/platform2_test.py \
		--sysroot "${ROOT}" --run_as_root -- /usr/bin/fc-cache -f -v
}

pkg_preinst() {
	generate_font_cache
}
