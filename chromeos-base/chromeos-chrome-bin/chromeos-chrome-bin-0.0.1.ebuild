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
CHROME_BASE=${CHROME_BASE:-"http://build.chromium.org/buildbot/snapshots/chromium-rel-linux-chromiumos"}

DEPEND=""
RDEPEND="chromeos-base/chromeos-theme
         dev-libs/atk
         dev-libs/glib
         dev-libs/nspr
         dev-libs/nss
         gnome-base/gconf
         x11-libs/cairo
         x11-libs/libXScrnSaver
         x11-libs/gtk+
         x11-libs/pango
         media-libs/alsa-lib
         media-libs/fontconfig
         media-libs/freetype
         media-libs/jpeg
         sys-libs/zlib"

src_unpack() {
  if [ -z "${CHROME_BUILD}" ]; then
    elog "Finding latest Chrome build"
    CHROME_BUILD=$(wget -q -O - "${CHROME_BASE}"/LATEST)
  fi
  test -n "${CHROME_BUILD}" || die CHROME_BUILD not set
  elog "Fetching Chrome build $CHROME_BUILD"
  FILENAME="chrome-linux.zip"
  URL="${CHROME_BASE}/${CHROME_BUILD}/${FILENAME}"
  
  mkdir -p "${S}"
  cd "${S}"
  wget "${URL}" || die Download "${URL}" failed
  unzip "${FILENAME}" || die unzip failed
  
  rm "${FILENAME}"
}

src_install() {
  local chrome_dir="/opt/google/chrome"
  local dest="${D}/${chrome_dir}"

  dodir "${chrome_dir}"

  cp -a "${S}"/chrome-linux/* "${dest}"

  # TODO(adlr): replace 1000 with 'chronos' gid
  chown root:1000 "${dest}/session" || die "chown failed"
  chmod 6755 "${dest}/session" || die "chmod failed"
  chmod 6755 "${dest}/emit_login_prompt_ready" || die "chmod failed"

  local platform="${CHROMEOS_ROOT}/src/platform/"
  
  insinto "${chrome_dir}"
  insopts -m0755
  doins "${platform}"/chrome/bottle.sh
  doins "${platform}"/chrome/log.sh

  insinto /usr/bin
  doins "${platform}"/chrome/chromeos-chrome-loop
  
  # Fix some perms
  chmod -R a+r "${D}"
  find "${D}" -perm /111 -print0 | xargs -0 chmod a+x 

  # The following symlinks are needed in order to run chrome.
  dosym nss/libnss3.so /usr/lib/libnss3.so.1d
  dosym nss/libnssutil3.so.12 /usr/lib/libnssutil3.so.1d
  dosym nss/libsmime3.so.12 /usr/lib/libsmime3.so.1d
  dosym nss/libssl3.so.12 /usr/lib/libssl3.so.1d
  dosym nspr/libplds4.so /usr/lib/libplds4.so.0d
  dosym nspr/libplc4.so /usr/lib/libplc4.so.0d
  dosym nspr/libnspr4.so /usr/lib/libnspr4.so.0d
}
