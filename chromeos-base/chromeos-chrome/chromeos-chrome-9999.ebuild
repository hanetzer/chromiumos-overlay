# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/chromium/chromium-9999.ebuild,v 1.2 2009/10/02 14:29:23 voyageur Exp $

# Usage: by default, downloads chromium browser from the build server.
# If CHROME_ORIGIN is set to one of {SERVER_BINARY,LOCAL_SOURCE,LOCAL_BINARY},
# The build comes from the build server, locally provided source, or
# precompiled locally provided source, respectively.
# If building from either LOCAL_SOURCE or LOCAL_BINARY, specifying BUILDTYPE
# will allow you to specify "Debug" or another build type; "Release" is
# the default.
# If getting it from the build server, setting CHROME_BUILD to the build
# revision will pull that version, otherwise latest will be pulled.

# gclient is expected to be in ~/depot_tools if EGCLIENT is not set
# to gclient path.

EAPI="2"
inherit eutils multilib toolchain-funcs

DESCRIPTION="Open-source version of Google Chrome web browser"
HOMEPAGE="http://chromium.org/"
EGCLIENT_REPO_URI="http://src.chromium.org/svn/trunk/src/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="x86 arm"
IUSE=""

# By default, pull from server
CHROME_ORIGIN="${CHROME_ORIGIN:-SERVER_BINARY}"

# For compilation/local chrome
BUILD_TOOL=make
BUILD_DEFINES="sysroot=$ROOT disable_nacl=1 linux_use_tcmalloc=0 chromeos=1"
BUILDTYPE="${BUILDTYPE:-Release}"

# For pulling from build bot
CHROME_BASE=${CHROME_BASE:-"http://build.chromium.org/buildbot/snapshots/chromium-rel-linux-chromiumos"}

RDEPEND="app-arch/bzip2
         chromeos-base/chromeos-theme
         dev-libs/atk
         dev-libs/glib
         dev-libs/nspr
         >=dev-libs/nss-3.12.2
         dev-libs/libxml2
         >=gnome-base/gconf-2.24.0
         x11-libs/cairo
         x11-libs/libXScrnSaver
         x11-libs/gtk+
         x11-libs/pango
         >=media-libs/alsa-lib-1.0.19
         media-libs/fontconfig
         media-libs/freetype
         media-libs/jpeg
         media-libs/libpng
         media-libs/mesa
         sys-libs/zlib
	 x86? ( www-plugins/adobe-flash )
         >=x11-libs/gtk+-2.14.7
         x11-libs/libXScrnSaver"
DEPEND="${RDEPEND}
        >=dev-util/gperf-3.0.3
        >=dev-util/pkgconfig-0.23"

export CHROMIUM_HOME=/usr/$(get_libdir)/chromium-browser

HH="${HOME}"

src_unpack() {
  # These are set here because $(whoami) returns the proper user here,
  # but 'root' at the root level of the file
  export CHROME_ROOT="${CHROME_ROOT:-/home/$(whoami)/chrome_root}"
  export EGCLIENT="${EGCLIENT:-/home/$(whoami)/depot_tools/gclient}"

  case "${CHROME_ORIGIN}" in
    SERVER_BINARY|LOCAL_SOURCE|LOCAL_BINARY)
      ;;
    *)
      die CHROME_ORIGIN not one of SERVER_BINARY, LOCAL_SOURCE, LOCAL_BINARY
      ;;
  esac

  if [ "$CHROME_ORIGIN" = "SERVER_BINARY" ]; then
    # Using build server.

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
  else
    # Using local source
    if [ "$CHROME_ORIGIN" = "LOCAL_SOURCE" ]; then
      # Set proper BUILD_DEFINES for the arch
      if [ "$ARCH" = "x86" ]; then
        BUILD_DEFINES="target_arch=ia32 $BUILD_DEFINES";
      elif [ "$ARCH" = "arm" ]; then
        BUILD_DEFINES="target_arch=arm $BUILD_DEFINES armv7=1";
      else
        die Unsupported architecture: "$ARCH"
      fi
    
      # This saves time and bytes.
      if [ "${REMOVE_WEBCORE_DEBUG_SYMBOLS:-1}" = "1" ]; then
        BUILD_DEFINES="$BUILD_DEFINES remove_webcore_debug_symbols=1"
      fi
      
      export GYP_GENERATORS="${BUILD_TOOL}"
      export GYP_DEFINES="${BUILD_DEFINES}"
      # Prevents gclient from updating self.
      export DEPOT_TOOLS_UPDATE=0
    fi
  fi
}

src_prepare() {
  if [ "$CHROME_ORIGIN" != "LOCAL_SOURCE" ]; then
    return
  fi

  cd "${CHROME_ROOT}"/src || die

  test -n "${EGCLIENT}" || die EGCLIENT unset
  ${EGCLIENT} runhooks --force
}

src_compile() {
  if [ "$CHROME_ORIGIN" != "LOCAL_SOURCE" ]; then
    return
  fi

  cd "${CHROME_ROOT}"/src || die
  emake -r V=1 BUILDTYPE="${BUILDTYPE}" \
    CXX=$(tc-getCXX) \
    CC=$(tc-getCC) \
    AR=$(tc-getAR) \
    AS=$(tc-getAS) \
    RANLIB=$(tc-getRANLIB) \
    LD=$(tc-getLD) \
    chrome candidate_window session \
    || die "compilation failed"
}

src_install() {
  if [ "${CHROME_ORIGIN}" = "SERVER_BINARY" ]; then
    FROM="${S}"/chrome-linux
  else
    FROM="${CHROME_ROOT}/src/out/${BUILDTYPE}"
  fi

  # First, things from the chrome build output directory
  CHROME_DIR=/opt/google/chrome
  D_CHROME_DIR="${D}/${CHROME_DIR}"

  dodir "${CHROME_DIR}"
  dodir "${CHROME_DIR}"/plugins

  exeinto "${CHROME_DIR}"
  doexe "${FROM}"/candidate_window
  doexe "${FROM}"/chrome
  doexe "${FROM}"/session
  # TODO(adlr): replace 1000 with 'chronos' gid
  chown root:1000 "${D_CHROME_DIR}/session" || die "chown failed"
  chmod 6755 "${D_CHROME_DIR}/session" || die "chmod failed"
  
  insinto "${CHROME_DIR}"
  doins "${FROM}"/chrome-wrapper
  doins "${FROM}"/chrome.pak
  doins "${FROM}"/emit_login_prompt_ready
  chmod 6755 "${D_CHROME_DIR}/emit_login_prompt_ready" || die "chmod failed"
  doins "${FROM}"/libffmpegsumo.so
  doins -r "${FROM}"/locales
  doins -r "${FROM}"/resources
  doins "${FROM}"/xdg-settings
  doins "${FROM}"/*.png

  # Next, some scripts from the chromeos source tree
  PLATFORM_CHROME="${CHROMEOS_ROOT}"/src/platform/chrome
  
  doins "${PLATFORM_CHROME}"/bottle.sh
  doins "${PLATFORM_CHROME}"/log.sh
  
  insinto /usr/bin
  doins "${PLATFORM_CHROME}"/chromeos-chrome-loop

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
  
  dosym /opt/netscape/plugins/libflashplayer.so \
    "${CHROME_DIR}"/plugins/libflashplayer.so 
}
