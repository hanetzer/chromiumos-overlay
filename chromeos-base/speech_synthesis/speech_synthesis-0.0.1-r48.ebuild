# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
CROS_WORKON_COMMIT="b5cb983a3e9ed25949c35defdda52fde3023f574"
CROS_WORKON_TREE="e5949acbe723c1ff2a444140db63fcc8ab110a36"

EAPI="4"
CROS_WORKON_PROJECT="chromiumos/platform/speech_synthesis"

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="This is the text-to-speech (TTS) synthesis library"
HOMEPAGE="http://www.svox.com/"
SRC_URI=""

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

DEPEND="chromeos-base/libchrome:85268[cros-debug=]
	chromeos-base/libchromeos
	chromeos-base/system_api
	dev-libs/dbus-glib
	dev-libs/glib
	dev-libs/libxml2
	media-libs/alsa-lib
	media-libs/libresample
	media-libs/pico"
RDEPEND="${DEPEND}"

src_prepare() {
	tc-export CXX
	cros-debug-add-NDEBUG
}

src_install() {
	dosbin speech_synthesizer

	insinto /etc/dbus-1/system.d
	doins SpeechSynthesizer.conf

	insinto /usr/share/dbus-1/system-services
	doins org.chromium.SpeechSynthesizer.service
}

