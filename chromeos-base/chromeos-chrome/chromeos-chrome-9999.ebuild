# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/chromium/chromium-9999.ebuild,v 1.2 2009/10/02 14:29:23 voyageur Exp $

EAPI="2"
inherit eutils multilib toolchain-funcs

DESCRIPTION="Open-source version of Google Chrome web browser"
HOMEPAGE="http://chromium.org/"
EGCLIENT_REPO_URI="http://src.chromium.org/svn/trunk/src/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="x86 arm"
IUSE=""

BUILD_TOOL=make
BUILD_DEFINES="sysroot=$ROOT disable_nacl=1 linux_use_tcmalloc=0 chromeos=1"
BUILDTYPE="${BUILDTYPE:-Release}"

#dev-libs/libxslt

RDEPEND="app-arch/bzip2
  dev-libs/libxml2
  >=dev-libs/nss-3.12.2
  >=gnome-base/gconf-2.24.0
  media-fonts/corefonts
  >=media-libs/alsa-lib-1.0.19
  media-libs/jpeg
  media-libs/libpng
  media-libs/mesa
  sys-libs/zlib
  >=x11-libs/gtk+-2.14.7
  x11-libs/libXScrnSaver"
DEPEND="${RDEPEND}
  >=dev-util/gperf-3.0.3
  >=dev-util/pkgconfig-0.23
  dev-util/subversion"

export CHROMIUM_HOME=/usr/$(get_libdir)/chromium-browser

src_unpack() {
  if [ -z "${CHROMEOS_ROOT}" ]; then
    die CHROMEOS_ROOT unset
  fi

  if [ "$CHROME_SKIP_BUILD" == "1" ]; then
    if [ -z "${CHROME_ROOT}" ]; then
      die "Skipping build, but CHROME_ROOT is unset"
    fi
    return;
  fi

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

  if [ ! -z "${CHROME_ROOT}" ]; then
    einfo "using existing chrome at ${CHROME_ROOT}"
    if [ -z "$EGCLIENT" ]; then
      die "Using existing chrome, but EGCLIENT not set to gclient full path"
    fi
  else
    einfo "checking out chrome source"

    #subversion_src_unpack
    mkdir -p "${S}"
    cd "${S}"
    svn co "http://src.chromium.org/svn/trunk/tools/depot_tools"
  
    mv "${S}"/depot_tools "${WORKDIR}"/depot_tools

    # Most subversion checks and configurations were already run
    EGCLIENT="${WORKDIR}"/depot_tools/gclient
  
    mkdir -p "${S}" || die
    cd "${S}" || die

    einfo "gclient config -->"
    ${EGCLIENT} config ${EGCLIENT_REPO_URI} || \
      die "gclient: error creating config"
    epatch "${FILESDIR}"/chromeos-chrome-gclient.patch || \
      die "gclient patch failed"

    ${EGCLIENT} sync || die "gclient sync failed"
  fi
}

src_prepare() {
  if [ "$CHROME_SKIP_BUILD" == "1" ]; then
    return;
  fi

  if [ ! -z "${CHROME_ROOT}" ]; then
    elog cd-ing to "$CHROME_ROOT"
    cd "${CHROME_ROOT}"
  fi

  einfo "it's okay for this patch to fail:"
  patch -f -p1 < "${FILESDIR}"/chromeos-chrome-9999-pkgconfig.patch

  if [ -z "${EGCLIENT}" ]; then
    die EGCLIENT unset
  fi

  cd src || die

  ${EGCLIENT} runhooks --force
}

src_compile() {
  if [ "$CHROME_SKIP_BUILD" == "1" ]; then
    return;
  fi

  if [ ! -z "${CHROME_ROOT}" ]; then
    cd "${CHROME_ROOT}"
  else
    cd "${S}"
  fi

  cd src || die
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
  if [ -z "${CHROME_ROOT}" ]; then
    CHROME_ROOT="${S}"
  fi

  # First, things from the chrome build output directory
  CHROME_DIR=/opt/google/chrome
  dodir "${CHROME_DIR}"

  exeinto "${CHROME_DIR}"
  doexe "${CHROME_ROOT}"/src/out/"${BUILDTYPE}"/candidate_window
  doexe "${CHROME_ROOT}"/src/out/"${BUILDTYPE}"/chrome
  doexe "${CHROME_ROOT}"/src/out/"${BUILDTYPE}"/session
  
  insinto "${CHROME_DIR}"
  doins "${CHROME_ROOT}"/src/out/"${BUILDTYPE}"/chrome-wrapper
  doins "${CHROME_ROOT}"/src/out/"${BUILDTYPE}"/chrome.pak
  doins "${CHROME_ROOT}"/src/out/"${BUILDTYPE}"/emit_login_prompt_ready
  doins "${CHROME_ROOT}"/src/out/"${BUILDTYPE}"/libffmpegsumo.so
  doins -r "${CHROME_ROOT}"/src/out/"${BUILDTYPE}"/locales
  doins -r "${CHROME_ROOT}"/src/out/"${BUILDTYPE}"/resources
  doins "${CHROME_ROOT}"/src/out/"${BUILDTYPE}"/xdg-settings
  doins "${CHROME_ROOT}"/src/out/"${BUILDTYPE}"/*.png

  # Next, some scripts from the chromeos source tree
  PLATFORM_CHROME="${CHROMEOS_ROOT}"/src/platform/chrome
  
  doins "${PLATFORM_CHROME}"/bottle.sh
  doins "${PLATFORM_CHROME}"/log.sh
  
  insinto /usr/bin
  doins "${PLATFORM_CHROME}"/chromeos-chrome-loop
}
