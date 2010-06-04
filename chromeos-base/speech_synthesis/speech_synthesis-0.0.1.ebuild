# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils

DESCRIPTION="This is the text-to-speech (TTS) synthesis library."
HOMEPAGE="http://www.svox.com"
SRC_URI=""
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="x86"
IUSE=""
DEPEND="chromeos-base/libchrome
	chromeos-base/libchromeos
	dev-libs/dbus-glib
	dev-libs/glib
	media-libs/alsa-lib
	media-libs/libresample
	media-libs/pico
	media-sound/pulseaudio"

RDEPEND="${DEPEND}"

src_unpack() {
	local platform="${CHROMEOS_ROOT}/src/platform/"
	elog "Using platform: $platform"
	mkdir -p "${S}"
	cp -a "${platform}"/speech_synthesis/* "${S}" || die
}

src_compile() {
	tc-getCXX
	emake -j1 || die "emake failed"
}

src_install() {
	dosbin "${S}/speech_synthesizer"
	dosbin "${S}/speech_synthesizer_client"

	insinto /etc/dbus-1/system.d
	doins "${S}/SpeechSynthesizer.conf"

	insinto /usr/share/dbus-1/system-services
	doins "${S}/org.chromium.SpeechSynthesizer.service"

	dolib "${S}/libtts.so"
}
