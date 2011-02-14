# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit cros-workon toolchain-funcs

DESCRIPTION="Audio configuration files."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="-pulseaudio_cros"

RDEPEND=""
DEPEND="${RDEPEND}"

CROS_WORKON_PROJECT="audioconfig"
CROS_WORKON_LOCALNAME="${CROS_WORKON_PROJECT}"

src_install() {
	if use pulseaudio_cros; then
		dodir /etc
		insinto /etc
		doins "${S}"/asound.conf

		# The pulseaudio configuration files must be patched by the pulseaudio
		# ebuild which installs them. Given that we're not using pulseaudio
		# right now and we'll be removing it from the image, just die.
		die "pulseaudio is not supported"
		dodir /etc/pulse
		insinto /etc/pulse
		doins "${S}"/pulse/*
	fi
}
