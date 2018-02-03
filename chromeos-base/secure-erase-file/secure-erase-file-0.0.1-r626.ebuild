# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT="ac53135191d3f3a0db2c1d5c682afd5911984024"
CROS_WORKON_TREE="9f455dbf5284032855a88de3110768344349a632"
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
