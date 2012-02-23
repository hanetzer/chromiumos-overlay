# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

DESCRIPTION="Chrome OS Fonts (meta package)"
HOMEPAGE="http://src.chromium.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="internal"

# List of font packages used in Chromium OS.  This list is separate
# so that it can be shared between the host in
# chromeos-base/hard-host-depends and the target in
# chromeos-base/chromeos.
RDEPEND="
	media-fonts/croscorefonts
	media-fonts/dejavu
	media-fonts/droidfonts-cros
	!internal? ( media-fonts/ja-ipafonts )
	media-fonts/ko-nanumfonts
	media-fonts/lohitfonts-cros
	media-fonts/ml-anjalioldlipi
	media-fonts/sil-abyssinica
	"
