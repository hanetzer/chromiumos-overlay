# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT="1644ba1ae628c5d11d1c38aff204ec5ee17a8fc4"
CROS_WORKON_TREE="30ad12e6e303df8b140d36c89bddfcadde52bfe2"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="secure_erase_file"

inherit cros-workon platform

DESCRIPTION="Secure file erasure for Chrome OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/secure_erase_file/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="
	chromeos-base/libbrillo
"

RDEPEND="
	${DEPEND}
"

src_install() {
	dobin "${OUT}/secure_erase_file"
	dolib.so "${OUT}/lib/libsecure_erase_file.so"
}
