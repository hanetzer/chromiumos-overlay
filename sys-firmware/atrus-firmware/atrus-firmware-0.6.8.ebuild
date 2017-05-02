# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

DESCRIPTION="Atrus speaker/microphone firmware"
HOMEPAGE="http://www.limesaudio.com/"
SRC_URI="gs://chromeos-localmirror/distfiles/atrus-firmware-${PV}.tgz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"

RDEPEND="chromeos-base/atrusctl"
DEPEND=""

S="${WORKDIR}"

src_install() {
	insinto "/lib/firmware/limes_audio/"
	doins "atrus-fw-bundle-v${PV}.bin"
	dosym "atrus-fw-bundle-v${PV}.bin" \
		"/lib/firmware/limes_audio/atrus-fw-bundle.bin"
}
