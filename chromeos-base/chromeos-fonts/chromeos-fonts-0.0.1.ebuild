# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

DESCRIPTION="Chrome OS Fonts (meta package)"
HOMEPAGE="http://src.chromium.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="internal"

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
RDEPEND="
	$JA_FONTS
	media-fonts/croscorefonts
	media-fonts/dejavu
	media-fonts/droidfonts-cros
	media-fonts/ko-nanumfonts
	media-fonts/lohitfonts-cros
	media-fonts/ml-anjalioldlipi
	media-fonts/sil-abyssinica
	"
