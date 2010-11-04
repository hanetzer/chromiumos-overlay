# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# Usage: by default, downloads chromium browser from the build server.
# If CHROME_ORIGIN is set to one of {SERVER_SOURCE, LOCAL_SOURCE},
# The build comes from the chromimum source repository (gclient sync), \
# build server, locally provided source, or locally provided binary
# If you are using SERVER_SOURCE, a gclient tempalte file that is in the files
# directory, which will be copied automatically during the build and used as
# the .gclient for 'gclient sync'
# If building from LOCAL_SOURCE or LOCCAL_BINARY specifying BUILDTYPE
# will allow you to specify "Debug" or another build type; "Release" is
# the default.
# If getting it from the build server, setting CHROME_VERSION to the build
# revision will pull that version, otherwise latest will be pulled.

# gclient is expected to be in ~/depot_tools if EGCLIENT is not set
# to gclient path.

EAPI="2"
inherit eutils multilib toolchain-funcs flag-o-matic autotest

DESCRIPTION="Open-source version of Google Chrome web browser"
HOMEPAGE="http://chromium.org/"
SRC_URI=""
EGCLIENT_REPO_URI="WE USE A GCLIENT TEMPLATE FILE IN THIS DIRECTORY"

LICENSE="BSD"
SLOT="0"
KEYWORDS="x86 arm"
IUSE="+build_tests x86 gold +chrome_remoting"

# chrome sources store directory
[[ -z ${ECHROME_STORE_DIR} ]] &&
ECHROME_STORE_DIR="${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}/chrome-src"
addwrite "${ECHROME_STORE_DIR}"

# chrome destination directory
CHROME_DIR=/opt/google/chrome
D_CHROME_DIR="${D}/${CHROME_DIR}"

# By default, pull from server
CHROME_ORIGIN="${CHROME_ORIGIN:-SERVER_SOURCE}"

# For compilation/local chrome
BUILD_TOOL=make

if [ "$ARCH" = "x86" ]; then
	BUILD_DEFINES="sysroot=$ROOT python_ver=2.6 swig_defines=-DOS_CHROMEOS linux_use_tcmalloc=0 chromeos=1 ${EXTRA_BUILD_ARGS}"
elif [ "$ARCH" = "arm" ]; then
	BUILD_DEFINES="sysroot=$ROOT python_ver=2.6 swig_defines=-DOS_CHROMEOS linux_use_tcmalloc=0 chromeos=1 linux_sandbox_path=${CHROME_DIR}/chrome-sandbox ${EXTRA_BUILD_ARGS}"
else
	die Unsupported architecture: "${ARCH}"
fi

BUILDTYPE="${BUILDTYPE:-Release}"
BOARD="${BOARD:-${SYSROOT##/build/}}"
BUILD_OUT="${BUILD_OUT:-${BOARD}_out}"
# WARNING: We are using a symlink now for the build directory to work around 
# command line length limits. This will cause problems if you are doing 
# parallel builds of different boards/variants.
# Unsetting BUILD_OUT_SYM will revert this behavior
BUILD_OUT_SYM="c"

# For pulling from build bot
if [ "$ARCH" = "x86" ]; then
	DEFAULT_CHROME_DIR=chromium-rel-linux-chromiumos
elif [ "$ARCH" = "arm" ]; then
	DEFAULT_CHROME_DIR=chromium-rel-arm
fi
CHROME_BASE=${CHROME_BASE:-"http://build.chromium.org/buildbot/snapshots/${DEFAULT_CHROME_DIR}"}

TEST_FILES="ffmpeg_tests
            omx_test"

RDEPEND="app-arch/bzip2
         chromeos-base/chromeos-theme
         chromeos-base/libcros
         chrome_remoting? ( x11-libs/libXtst )
         dev-libs/atk
         dev-libs/glib
         dev-libs/nspr
         >=dev-libs/nss-3.12.2
         dev-libs/libxml2
         dev-libs/dbus-glib
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
         media-sound/pulseaudio
         net-misc/wget
         sys-libs/zlib
         x86? ( www-plugins/adobe-flash )
         >=x11-libs/gtk+-2.14.7
         x11-libs/libXScrnSaver"

DEPEND="${RDEPEND}
        >=dev-util/gperf-3.0.3
        >=dev-util/pkgconfig-0.23"

AUTOTEST_COMMON="src/chrome/test/chromeos/autotest/files"
AUTOTEST_CLIENT_SITE_TESTS="${AUTOTEST_COMMON}/client/site_tests"
AUTOTEST_DEPS="${AUTOTEST_COMMON}/client/deps"
AUTOTEST_DEPS_LIST="chrome_test"

IUSE_TESTS="
	+tests_desktopui_BrowserTest
	+tests_desktopui_SyncIntegrationTests
	+tests_desktopui_UITest
	+tests_desktopui_PyAutoFunctionalTests
	"
IUSE="${IUSE} +autotest ${IUSE_TESTS}"

export CHROMIUM_HOME=/usr/$(get_libdir)/chromium-browser

QA_TEXTRELS="*"
QA_EXECSTACK="*"
QA_PRESTRIPPED="*"

# Must write our own. wget --tries ignores 'connection refused' or 'not found's
wget_retry() {
	local i=

	# Retry 3 times
	for i in $(seq 3); do
		# Buildbot will timeout and kill -9 @ 1200 seconds.  Get these retries done
		# before that happens in case wget read hangs.
		wget --timeout=30 $* && return 0
	done
	return 1
}

set_build_defines() {
	# Set proper BUILD_DEFINES for the arch
	if [ "$ARCH" = "x86" ]; then
		BUILD_DEFINES="target_arch=ia32 $BUILD_DEFINES";
	elif [ "$ARCH" = "arm" ]; then
		BUILD_DEFINES="target_arch=arm $BUILD_DEFINES armv7=1 disable_nacl=1";
	else
		die Unsupported architecture: "${ARCH}"
	fi

	# Control inclusion of optional chrome features.
	if use chrome_remoting; then
		BUILD_DEFINES="remoting=1 $BUILD_DEFINES"
	else
		BUILD_DEFINES="remoting=0 $BUILD_DEFINES"
	fi

	# This saves time and bytes.
	if [ "${REMOVE_WEBCORE_DEBUG_SYMBOLS:-1}" = "1" ]; then
		BUILD_DEFINES="$BUILD_DEFINES remove_webcore_debug_symbols=1"
	fi

	export GYP_GENERATORS="${BUILD_TOOL}"
	export GYP_DEFINES="${BUILD_DEFINES}"
	export builddir_name="${BUILD_OUT}"

	# Prevents gclient from updating self.
	export DEPOT_TOOLS_UPDATE=0
}

src_unpack() {
	# These are set here because $(whoami) returns the proper user here,
	# but 'root' at the root level of the file
	export CHROME_ROOT="${CHROME_ROOT:-/home/$(whoami)/chrome_root}"
	export EGCLIENT="${EGCLIENT:-/home/$(whoami)/depot_tools/gclient}"
	export DEPOT_TOOLS_UPDATE=0

	case "${CHROME_ORIGIN}" in
	LOCAL_SOURCE|SERVER_SOURCE|LOCAL_BINARY)
		elog "CHROME_ORIGIN VALUE is ${CHROME_ORIGIN}"
		;;
	*)
	die "CHROME_ORIGIN not one of LOCAL_SOURCE, SERVER_SOURCE, LOCAL_BINARY"
		;;
	esac

	case "$CHROME_ORIGIN" in
	(SERVER_SOURCE)
		# We are going to fetch source and build chrome

		# initial clone, we have to create chrome-src storage directory and play
		# nicely with sandbox
		if [[ ! -d ${ECHROME_STORE_DIR} ]] ; then
			debug-print "${FUNCNAME}: Creating chrome-src directory"
			addwrite /
			mkdir -p "${ECHROME_STORE_DIR}" \
				|| die "can't mkdir ${ECHROME_STORE_DIR}."
			export SANDBOX_WRITE="${SANDBOX_WRITE%%:/}"
		fi

		elog "Copying chromium.gclient  ${ECHROME_STORE_DIR}/.gclient"
		rm -f ${ECHROME_STORE_DIR}/.gclient

		cp -fp ${FILESDIR}/chromium.gclient ${ECHROME_STORE_DIR}/.gclient || \
			die "cannot copy chromium.gclient to ${ECHROME_STORE_DIR}/.gclient:$!"

		pushd "${ECHROME_STORE_DIR}" || \
			die "Cannot chdir to ${ECHROME_STORE_DIR}"

		elog "Syncing google chrome sources using ${EGCLIENT}"
		${EGCLIENT} sync  --nohooks --delete_unversioned_trees || \
			die "${EGCLIENT} sync failed"

		elog "set the LOCAL_SOURCE to  ${ECHROME_STORE_DIR}"
		elog "From this point onwards there is no difference between \
			SERVER_SOURCE and LOCAL_SOURCE, since the fetch is done"
		export CHROME_ROOT=${ECHROME_STORE_DIR}
		set_build_defines
		;;
	(LOCAL_SOURCE)
		set_build_defines
		;;
	esac

	# FIXME: This is the normal path where ebuild stores its working data.
	# Chrome builds inside distfiles because of speed, so we at least make
	# a symlink here to add compatibility with autotest eclass which uses this.
	ln -sf "${CHROME_ROOT}" "${WORKDIR}/${P}"
}

src_prepare() {
	if [[ "$CHROME_ORIGIN" != "LOCAL_SOURCE" ]] && [[ "$CHROME_ORIGIN" != "SERVER_SOURCE" ]]; then
		return
	fi

	elog "${CHROME_ROOT} should be set here properly"
	cd "${CHROME_ROOT}/src" || die "Cannot chdir to ${CHROME_ROOT}"

	# We do symlink creation here if appropriate
	if [ ! -z "${BUILD_OUT_SYM}" ]; then
		if [ -h "${BUILD_OUT_SYM}" ]; then  # remove if an existing symlink
			rm "${BUILD_OUT_SYM}"
		fi
		if [ ! -e "${BUILD_OUT_SYM}" ]; then
			if [ ! -d "${BUILD_OUT}" ]; then # Make sure the directory exists
				mkdir "${BUILD_OUT}"
			fi
			ln -s "${BUILD_OUT}" "${BUILD_OUT_SYM}"
			export builddir_name="${BUILD_OUT_SYM}"
		fi
	fi

	test -n "${EGCLIENT}" || die EGCLIENT unset

	[ -f "$EGCLIENT" ] || die EGCLIENT at "$EGCLIENT" does not exist

	${EGCLIENT} runhooks --force || die  "Failed to run  ${EGCLIENT} runhooks"
}
# Extract the version number from lines like:
# kCrosAPIMinVersion = 29,
# kCrosAPIVersion = 30
extract_cros_version() {
	NAME="$1"
	FILE="$2"
	VERSION=$(perl -ne "print \$1 if /^\\s*${NAME}\\s*=\\s*(\\d+)/" "$FILE")
	test -z "$VERSION" && die "Failed to get $NAME from $FILE"
	echo $VERSION
}

# Check the libcros version compatibility, like we do in libcros at run time.
# See also platform/cros/version_check.cc and load.cc.
check_cros_version() {
	# Get the version of libcros in the chromium tree.
	VERSION=$(extract_cros_version kCrosAPIVersion \
	"$CHROME_ROOT/src/third_party/cros/chromeos_cros_api.h")
	elog "Libcros version in chromium tree: $VERSION"

	# Get the min version of libcros in the chromium os tree.
	MIN_VERSION=$(extract_cros_version kCrosAPIMinVersion \
		"${SYSROOT}/usr/include/cros/chromeos_cros_api.h")
	elog "Libcros min version in chromium os tree: $MIN_VERSION"

	# Get the max version of libcros in the chromium os tree.
	MAX_VERSION=$(extract_cros_version kCrosAPIVersion \
		"${SYSROOT}/usr/include/cros/chromeos_cros_api.h")
	elog "Libcros max version in chromium os tree: $MAX_VERSION"

	if [ "$MIN_VERSION" -gt "$VERSION" ]; then
		die "Libcros version check failed. Forgot to sync the chromium tree?"
	fi
	if [ "$VERSION" -gt "$MAX_VERSION" ]; then
		die "Libcros version check failed. Forgot to sync the chromium os tree?"
	fi
}

src_compile() {
	if [[ "$CHROME_ORIGIN" != "LOCAL_SOURCE" ]] && [[ "$CHROME_ORIGIN" != "SERVER_SOURCE" ]]; then
		return
	fi

	check_cros_version

	cd "${CHROME_ROOT}"/src || die "Cannot chdir to ${CHROME_ROOT}/src"

	if use build_tests; then
		TEST_TARGETS="browser_tests
			page_cycler_tests
			reliability_tests
			sync_integration_tests
			startup_tests
			ui_tests"
		if use x86; then  # Build PyAuto on x86 only.
			TEST_TARGETS="${TEST_TARGETS} pyautolib"
		fi
		echo Building test targets: ${TEST_TARGETS}
	fi

	tc-export CXX CC AR AS RANLIB LD
	# HACK(zbehan): On x86, we have the option of using gold. This has to be
	# done in a manner specific for this ebuild until gold is stabilized for
	# the whole world. Current way is to pass a -B option to CC, CXX and LD,
	# which makes them use a different linker. This was suggested by raymes.
	if use x86 && use gold; then
		# List all gold binutils and pick the latest
		GOLDLOC=$(
	echo /usr/x86_64-pc-linux-gnu/i686-pc-linux-gnu/binutils-bin/*-gold | \
	tail -n 1)

		# GOLDLOC will either be the latest gold version or string with *
		if [ -d "${GOLDLOC}" ]; then
			einfo "Using gold in: ${GOLDLOC}"

			export CC="${CC} -B${GOLDLOC}"
			export CXX="${CXX} -B${GOLDLOC}"
			export LD="${GOLDLOC}/ld"
		else
			ewarn "Couldn't find gold, USE flag ignored."
		fi
	fi

	emake -r V=1 BUILDTYPE="${BUILDTYPE}" \
		chrome candidate_window chrome_sandbox default_extensions \
		${TEST_TARGETS} \
		|| die "compilation failed"

	if use build_tests; then
		install_chrome_test_resources "${WORKDIR}/test_src"
		# NOTE: Since chrome is built inside distfiles, we have to get
		# rid of the previous instance first.
		rm -rf "${WORKDIR}/${P}/${AUTOTEST_DEPS}/chrome_test/test_src"
		mv "${WORKDIR}/test_src" "${WORKDIR}/${P}/${AUTOTEST_DEPS}/chrome_test/"

		# HACK: It would make more sense to call autotest_src_prepare in
		# src_prepare, but we need to call install_chrome_test_resources first.
		autotest_src_prepare

		# Remove .svn dirs
		esvn_clean "${AUTOTEST_WORKDIR}"

		autotest_src_compile
	fi
}

fast_cp() {
	cp -l $* || cp $*
}

install_chrome_test_resources() {
	# NOTE: This is a duplicate from src_install, because it's required here.
	FROM="${CHROME_ROOT}/src/${BUILD_OUT}/${BUILDTYPE}"

	TEST_DIR="${1}"

	echo Copying Chrome tests into "${TEST_DIR}"
	mkdir -p "${TEST_DIR}/out/Release"

	# Copy PyAuto scripts and suppport libs.
	mkdir -p "${TEST_DIR}"/chrome/test
	fast_cp -a "${CHROME_ROOT}"/src/chrome/test/pyautolib \
		"${TEST_DIR}"/chrome/test/
	fast_cp -a "${CHROME_ROOT}"/src/chrome/test/functional \
		"${TEST_DIR}"/chrome/test/
	mkdir -p "${TEST_DIR}"/third_party
	fast_cp -a "${CHROME_ROOT}"/src/third_party/simplejson \
		"${TEST_DIR}"/third_party/
	fast_cp -a "${FROM}"/pyautolib.py "${TEST_DIR}"/out/Release

	fast_cp -a "${FROM}"/pyproto "${TEST_DIR}"/out/Release

	# When the splitdebug USE flag is used, debug info is generated for all
	# executables. We don't want debug info for tests, so we pre-strip these
	# executables.
	for f in lib.target/_pyautolib.so libppapi_tests.so browser_tests \
	         reliability_tests ui_tests sync_integration_tests \
	         page_cycler_tests; do
		fast_cp -a "${FROM}"/${f} "${TEST_DIR}"/out/Release
		$(tc-getSTRIP) --strip-unneeded ${TEST_DIR}/out/Release/$(basename ${f})
	done

	mkdir -p "${TEST_DIR}"/base
	fast_cp -a "${CHROME_ROOT}"/src/base/base_paths_posix.cc "${TEST_DIR}"/base

	mkdir -p "${TEST_DIR}"/chrome/test
	fast_cp -a "${CHROME_ROOT}"/src/chrome/test/data \
		"${TEST_DIR}"/chrome/test

	mkdir -p "${TEST_DIR}"/net/data/ssl
	fast_cp -a "${CHROME_ROOT}"/src/net/data/ssl/certificates \
		"${TEST_DIR}"/net/data/ssl

	mkdir -p "${TEST_DIR}"/net/tools
	fast_cp -a "${CHROME_ROOT}"/src/net/tools/testserver \
		"${TEST_DIR}"/net/tools

	mkdir -p "${TEST_DIR}"/third_party
	fast_cp -a "${CHROME_ROOT}"/src/third_party/tlslite \
		"${TEST_DIR}"/third_party
	fast_cp -a "${CHROME_ROOT}"/src/third_party/pyftpdlib \
		"${TEST_DIR}"/third_party
		
	mkdir -p "${TEST_DIR}"/third_party/WebKit/WebKitTools
	fast_cp -a "${CHROME_ROOT}"/src/third_party/WebKit/WebKitTools/Scripts \
		"${TEST_DIR}"/third_party/WebKit/WebKitTools

	for f in ${TEST_FILES}; do
		fast_cp -a "${FROM}/${f}" "${TEST_DIR}"
	done

	fast_cp -a "${CHROME_ROOT}"/"${AUTOTEST_DEPS}"/chrome_test/setup_test_links.sh \
		"${TEST_DIR}"/out/Release

	# Remove test binaries from other platforms
	if [ -z "${E_MACHINE}" ]; then
		echo E_MACHINE not defined!
	else
		cd "${TEST_DIR}"/chrome/test
		rm -fv $( scanelf -RmyBF%a . | grep -v -e ^${E_MACHINE} )
	fi
}

src_install() {
    FROM="${CHROME_ROOT}/src/${BUILD_OUT}/${BUILDTYPE}"

	# Override default strip flags and lose the '-R .comment'
	# in order to play nice with the crash server.
	if [ -z "${KEEP_CHROME_DEBUG_SYMBOLS}" ]; then
		export PORTAGE_STRIP_FLAGS="--strip-unneeded"
	else
		export PORTAGE_STRIP_FLAGS="--strip-debug --keep-file-symbols"
	fi

	# First, things from the chrome build output directory
	dodir "${CHROME_DIR}"
	dodir "${CHROME_DIR}"/plugins

	exeinto "${CHROME_DIR}"
	doexe "${FROM}"/candidate_window
	doexe "${FROM}"/chrome
	doexe "${FROM}"/libffmpegsumo.so

	if [ "$ARCH" = "arm" ]; then
		exeopts -m4755	# setuid the sandbox
		newexe "${FROM}/chrome_sandbox" chrome-sandbox
		exeopts -m0755
	fi

	# enable the chromeos local account, if the environment dictates
	if [ "${CHROMEOS_LOCAL_ACCOUNT}" != "" ]; then
		echo "${CHROMEOS_LOCAL_ACCOUNT}" > "${D_CHROME_DIR}/localaccount"
	fi

	insinto "${CHROME_DIR}"
	doins "${FROM}"/chrome-wrapper
	doins "${FROM}"/chrome.pak
	doins -r "${FROM}"/locales
	doins -r "${FROM}"/resources
        doins -r "${FROM}"/extensions
	doins "${FROM}"/resources.pak
	doins "${FROM}"/xdg-settings
	doins "${FROM}"/*.png

	# Chrome test resources
	# Test binaries are only available when building chrome from source
	if use build_tests && ([[ "${CHROME_ORIGIN}" = "LOCAL_SOURCE" ]] || \
		 [[ "${CHROME_ORIGIN}" = "SERVER_SOURCE" ]]); then
		autotest_src_install
	fi

	# Fix some perms
	chmod -R a+r "${D}"
	find "${D}" -perm /111 -print0 | xargs -0 chmod a+x

	# The following symlinks are needed in order to run chrome.
	dosym libnss3.so /usr/lib/libnss3.so.1d
	dosym libnssutil3.so.12 /usr/lib/libnssutil3.so.1d
	dosym libsmime3.so.12 /usr/lib/libsmime3.so.1d
	dosym libssl3.so.12 /usr/lib/libssl3.so.1d
	dosym libplds4.so /usr/lib/libplds4.so.0d
	dosym libplc4.so /usr/lib/libplc4.so.0d
	dosym libnspr4.so /usr/lib/libnspr4.so.0d

	# Use Flash from www-plugins/adobe-flash package.
	if use x86; then
		dosym /opt/netscape/plugins/libflashplayer.so \
			"${CHROME_DIR}"/plugins/libflashplayer.so
	fi
}
