# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"

DESCRIPTION="Chrome OS version of Chrome (binary package)"
HOMEPAGE="http://src.chromium.org"
LICENSE="BSD"
SLOT="0"
KEYWORDS="x86 arm"
IUSE=""

# TODO: If arm? then download the proper arm build.
CHROME_BUILD=${CHROME_BUILD:-"38617"}
CHROME_BASE=${CHROME_BASE:-"http://build.chromium.org/buildbot/snapshots/chromium-rel-linux-chromiumos"}
SRC_URI="${CHROME_BASE}/${CHROME_BUILD}/chrome-linux.zip"

# Chrome unpacks itself in a directory without the version number.
S="${WORKDIR}/chrome-linux"

DEPEND=""
RDEPEND="dev-libs/atk
	dev-libs/glib
	dev-libs/nspr
	dev-libs/nss
	gnome-base/gconf
	x11-libs/cairo
	x11-libs/gtk+
	x11-libs/pango
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype
	media-libs/jpeg
	sys-libs/zlib"

src_install() {
	local dest="${D}/opt/google/chrome"
	mkdir -p --mode=0755 "${dest}"
	cp -a "${S}"/* "${dest}" || die "install failed"

	local platform="${CHROMEOS_ROOT}/src/platform/"
	mkdir -p --mode=0755 "${D}/usr/bin"
	cp -a "${platform}"/chrome/chromeos-chrome-loop \
          "${D}"/usr/bin/chromeos-chrome-loop || die "install failed."
	cp -a "${platform}"/chrome/bottle.sh "${dest}" \
          || die "install failed."
	cp -a "${platform}"/chrome/log.sh "${dest}" \
          || die "install failed."
	chmod 0755 "${D}"/usr/bin/chromeos-chrome-loop \
          "${dest}/bottle.sh" "${dest}/log.sh" || die "install failed."

	# The following symlinks are needed in order to run chrome.
	mkdir -p --mode=0755 "${D}"/usr/lib
	ln -s nss/libnss3.so "${D}"/usr/lib/libnss3.so.1d
	ln -s nss/libnssutil3.so.12 "${D}"/usr/lib/libnssutil3.so.1d
	ln -s nss/libsmime3.so.12 "${D}"/usr/lib/libsmime3.so.1d
	ln -s nss/libssl3.so.12 "${D}"/usr/lib/libssl3.so.1d
	ln -s nspr/libplds4.so "${D}"/usr/lib/libplds4.so.0d
	ln -s nspr/libplc4.so "${D}"/usr/lib/libplc4.so.0d
	ln -s nspr/libnspr4.so "${D}"/usr/lib/libnspr4.so.0d
}
