# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="Audio configuration files."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"

ASOUNDCONF="${S}/${PN}/etc/asound.conf"
PULSE_DIR="${S}/${PN}/etc/pulse"

src_unpack() {
	local audioconfig="${CHROMEOS_ROOT}/src/platform/audioconfig"
	elog "Using audioconfig: ${audioconfig}"
	mkdir -p $(dirname "${ASOUNDCONF}")
	cp -a "${audioconfig}"/asound.conf "${ASOUNDCONF}" || die

	mkdir -p "${PULSE_DIR}"
	cp -a "${audioconfig}"/pulse/* "${PULSE_DIR}" || die
}

src_install() {
	dodir /etc
	insinto /etc
	doins "${ASOUNDCONF}"

	dodir /etc/pulse
	insinto /etc/pulse
	doins "${PULSE_DIR}"/*
}
