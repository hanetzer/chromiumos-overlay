# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

DESCRIPTION="Atrus speakerphone firmware"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/third_party/atrusctl/"
SRC_URI="gs://chromeos-localmirror/distfiles/atrus-firmware-${PV}.tgz"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="chromeos-base/atrusctl"
DEPEND=""

S="${WORKDIR}"

src_install() {
	insinto /lib/firmware/google/
	doins "atrus-fw-bundle-v${PV}.bin"
	dosym "atrus-fw-bundle-v${PV}.bin" \
		/lib/firmware/google/atrus-fw-bundle-latest.bin
}
