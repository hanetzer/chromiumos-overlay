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
# gclient is expected to be in ~/depot_tools if EGCLIENT is not set
# to gclient path.

EAPI="2"
CROS_SVN_COMMIT="72452"
inherit eutils multilib toolchain-funcs flag-o-matic autotest

DESCRIPTION="Open-source version of Google Chrome web browser"
HOMEPAGE="http://chromium.org/"
SRC_URI=""

KEYWORDS="~x86 ~arm"

LICENSE="BSD"
SLOT="0"
IUSE="+build_tests x86 +gold +chrome_remoting chrome_internal chrome_pdf +chrome_debug"

# Returns portage version without optional portage suffix.
# $1 - Version with optional suffix.
strip_portage_suffix() {
  echo "$1" | cut -f 1 -d "_"
}

CHROME_VERSION="$(strip_portage_suffix "${PV}")"

EXTERNAL_URL="http://src.chromium.org/svn"
INTERNAL_URL="svn://svn.chromium.org/chrome-internal"
[[ ( "${PV}" = "9999" ) || ( -n "${CROS_SVN_COMMIT}" ) ]]
USE_TRUNK=$?

REVISION="/${CHROME_VERSION}"
if [ ${USE_TRUNK} = 0 ]; then
	REVISION=
	if [ -n "${CROS_SVN_COMMIT}" ]; then
		REVISION="@${CROS_SVN_COMMIT}"
	fi
fi

if use chrome_internal; then
	if [ ${USE_TRUNK} = 0 ]; then
		PRIMARY_URL="${EXTERNAL_URL}/trunk/src"
		AUXILIARY_URL="${INTERNAL_URL}/trunk/src-internal"
	else
		PRIMARY_URL="${INTERNAL_URL}/trunk/tools/buildspec/releases"
		AUXILIARY_URL=
	fi
else
	if [ ${USE_TRUNK} = 0 ]; then
		PRIMARY_URL="${EXTERNAL_URL}/trunk/src"
	else
		PRIMARY_URL="${EXTERNAL_URL}/releases"
	fi
	AUXILIARY_URL=
fi

CHROME_SRC="chrome-src"
if use chrome_internal; then
	CHROME_SRC="${CHROME_SRC}-internal"
fi

# chrome sources store directory
if [[ -z ${ECHROME_STORE_DIR} ]] ; then
	ECHROME_STORE_DIR="${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}/${CHROME_SRC}"
fi
addwrite "${ECHROME_STORE_DIR}"

# chrome destination directory
CHROME_DIR=/opt/google/chrome
D_CHROME_DIR="${D}/${CHROME_DIR}"

# By default, pull from server
CHROME_ORIGIN="${CHROME_ORIGIN:-SERVER_SOURCE}"

# For compilation/local chrome
BUILD_TOOL=make
BUILD_DEFINES="sysroot=$ROOT python_ver=2.6 swig_defines=-DOS_CHROMEOS linux_use_tcmalloc=0 chromeos=1 linux_sandbox_path=${CHROME_DIR}/chrome-sandbox ${EXTRA_BUILD_ARGS}"
BUILDTYPE="${BUILDTYPE:-Release}"
BOARD="${BOARD:-${SYSROOT##/build/}}"
BUILD_OUT="${BUILD_OUT:-out_${BOARD}}"
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
CHROME_BASE=${CHROME_BASE:-"http://build.chromium.org/f/chromium/snapshots/${DEFAULT_CHROME_DIR}"}

TEST_FILES="ffmpeg_tests
            omx_test"

RDEPEND="${RDEPEND}
	 app-arch/bzip2
         chromeos-base/chromeos-theme
         chromeos-base/libcros
         chrome_remoting? ( x11-libs/libXtst )
         dev-libs/atk
         dev-libs/glib
         dev-libs/nspr
         >=dev-libs/nss-3.12.2
         dev-libs/libxml2
         dev-libs/dbus-glib
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

DEPEND="${DEPEND}
	${RDEPEND}
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

set_build_defines() {
	# Set proper BUILD_DEFINES for the arch
	if [ "$ARCH" = "x86" ]; then
		BUILD_DEFINES="target_arch=ia32 $BUILD_DEFINES";
	elif [ "$ARCH" = "arm" ]; then
		BUILD_DEFINES="target_arch=arm $BUILD_DEFINES armv7=1 disable_nacl=1";
		if use chrome_internal; then
			#http://code.google.com/p/chrome-os-partner/issues/detail?id=1142
			BUILD_DEFINES="$BUILD_DEFINES internal_pdf=0";
		fi
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

	if use chrome_internal; then
		#Adding chrome branding specific variables and GYP_DEFINES
		BUILD_DEFINES="branding=Chrome buildtype=Official $BUILD_DEFINES"
		export CHROMIUM_BUILD='_google_Chrome'
		export OFFICIAL_BUILD='1'
		export CHROME_BUILD_TYPE='_official'
	fi
	export GYP_GENERATORS="${BUILD_TOOL}"
	export GYP_DEFINES="${BUILD_DEFINES}"
	export builddir_name="${BUILD_OUT}"

	# Prevents gclient from updating self.
	export DEPOT_TOOLS_UPDATE=0
}

create_gclient_file() {
	local echrome_store_dir=${1}
	local primary_url=${2}
	local auxiliary_url=${3}
	local revision=${4}
	local use_pdf=${5}
	local use_trunk=${6}

	local pdf1="\"src/pdf\": None,"
	local pdf2="\"src-pdf\": None,"
	local checkout_point="CHROME_DEPS"

	if [ ${use_pdf} = 0 ]; then
		pdf1=
		pdf2=
	fi
	if [ ${use_trunk} = 0 ]; then
		checkout_point="src"
	fi
	echo "solutions = [" >${echrome_store_dir}/.gclient
	cat >>${echrome_store_dir}/.gclient <<EOF
  { "name"        : "${checkout_point}",
    "url"         : "${primary_url}${revision}",
    "custom_deps" : {
      "src/third_party/WebKit/LayoutTests": None,
      $pdf1
      $pdf2
    },
  },
EOF
	if [ -n "${auxiliary_url}" ]; then
		cat >>${echrome_store_dir}/.gclient <<EOF
  { "name"        : "aux_src",
    "url"         : "${auxiliary_url}${revision}",
  },
EOF
	fi
	if [ ${use_trunk} = 0 ]; then
		cat >>${echrome_store_dir}/.gclient <<EOF
  { "name"        : "cros",
    "url"         : "${primary_url}/tools/cros.DEPS${revision}",
  },
EOF
	fi
	echo "]" >>${echrome_store_dir}/.gclient
}

unpack_chrome() {
	# initial clone, we have to create chrome-src storage
	# directory and play nicely with sandbox
	if [[ ! -d ${ECHROME_STORE_DIR} ]] ; then
		debug-print "${FUNCNAME}: Creating chrome-src directory"
		addwrite /
		mkdir -p "${ECHROME_STORE_DIR}" \
			|| die "can't mkdir ${ECHROME_STORE_DIR}."
		export SANDBOX_WRITE="${SANDBOX_WRITE%%:/}"
	fi

	elog "Storing CHROME_VERSION=${CHROME_VERSION} in \
		${CHROME_VERSION_FILE} file"
	echo ${CHROME_VERSION} > ${CHROME_VERSION_FILE}

	elog "Creating ${ECHROME_STORE_DIR}/.gclient"
	#until we make the pdf compile on arm.
	#http://code.google.com/p/chrome-os-partner/issues/detail?id=1572
	if use chrome_pdf && use x86; then
		elog "Official Build enabling PDF sources"
		create_gclient_file "${ECHROME_STORE_DIR}" \
			"${PRIMARY_URL}" \
			"${AUXILIARY_URL}" \
			"${REVISION}" \
			0 \
			${USE_TRUNK} \
			|| die "Can't write .gclient file"
	else
		create_gclient_file "${ECHROME_STORE_DIR}" \
			"${PRIMARY_URL}" \
			"${AUXILIARY_URL}" \
			"${REVISION}" \
			1 \
			${USE_TRUNK} \
			|| die "Can't write .gclient file"
		BUILD_DEFINES="$BUILD_DEFINES internal_pdf=0";
	fi

	elog "Using .gclient ..."
	elog $(cat ${ECHROME_STORE_DIR}/.gclient)

	pushd "${ECHROME_STORE_DIR}" || \
		die "Cannot chdir to ${ECHROME_STORE_DIR}"

	elog "Syncing google chrome sources using ${EGCLIENT}"
	# We use --force to work around a race condition with
	# checking out cros.git in parallel with the main chrome tree.
	${EGCLIENT} sync --jobs 8 --nohooks --delete_unversioned_trees --force
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
		SUBVERSION_CONFIG_DIR=/home/$(whoami)/.subversion
		SSH_CONFIG_DIR=/home/$(whoami)/.ssh

		elog "Copying subversion credentials from \
			${SUBVERSION_CONFIG_DIR} into  ${HOME} if exists"

		if [ -d ${SUBVERSION_CONFIG_DIR} ]; then
			# TODO(anush): investigate this creating of $HOME
			mkdir -p ${HOME}
			elog  "Copying ${SUBVERSION_CONFIG_DIR} ${HOME}"
			cp -rfp ${SUBVERSION_CONFIG_DIR} ${HOME} \
			|| die "failed to copy svn credentials into ${HOME}"
			cp -rfp ${SSH_CONFIG_DIR} ${HOME} \
			|| die "failed to copy ssh credentials into ${HOME}"
		fi

		elog "Using CHROME_VERSION = ${CHROME_VERSION}"
		#See if the CHROME_VERSION we used previously was different
		CHROME_VERSION_FILE=${ECHROME_STORE_DIR}/chrome_version
		if [ -f ${CHROME_VERSION_FILE} ]; then
			OLD_CHROME_VERSION=$(cat ${CHROME_VERSION_FILE})
		fi

		if ! unpack_chrome; then
			if [ $OLD_CHROME_VERSION != $CHROME_VERSION ]; then
				popd
				elog "${EGCLIENT} sync failed and detected version change"
				elog "Attempting to clean up ${ECHROME_STORE_DIR} and retry"
				elog "OLD CHROME = ${OLD_CHROME_VERSION}"
				elog "NEW CHROME = ${CHROME_VERSION}"
				elog "rm -rf ${ECHROME_STORE_DIR}"
				rm -rf "${ECHROME_STORE_DIR}"
				sync
				unpack_chrome || die "${EGCLIENT} sync failed from fresh checkout"
			else
				die "${EGCLIENT} sync failed"
			fi
		fi

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

	# If there's already a build directory in the old location, rename it to the
	# new location.
	# TODO(derat): Remove this in January 2011.
	OLD_BUILD_OUT="${BOARD}_out"
	if [[ -d "${OLD_BUILD_OUT}" && ! -e "${BUILD_OUT}" ]]; then
		elog "Renaming output directory ${OLD_BUILD_OUT} to ${BUILD_OUT}"
		mv "${OLD_BUILD_OUT}" "${BUILD_OUT}"
	fi

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
	elog "Chromium is compatible with libcros API version $VERSION"

	# Get the min version of libcros in the chromium os tree.
	MIN_VERSION=$(extract_cros_version kCrosAPIMinVersion \
		"${SYSROOT}/usr/include/cros/chromeos_cros_api.h")
	elog "Libcros provides at least API version $MIN_VERSION"

	# Get the max version of libcros in the chromium os tree.
	MAX_VERSION=$(extract_cros_version kCrosAPIVersion \
		"${SYSROOT}/usr/include/cros/chromeos_cros_api.h")
	elog "Libcros provides at most API version $MAX_VERSION"

	if [ "$MIN_VERSION" -gt "$VERSION" ]; then
		die "Libcros version check failed. Forgot to sync the chromium tree?"
	fi
	if [ "$VERSION" -gt "$MAX_VERSION" ]; then
		die "Libcros version check failed. Forgot to sync the chromium os tree?"
	fi
}

strip_chrome_debug() {
	echo ${1} | sed -e "s/\s\(-gstabs\|-ggdb\|-gdwarf\S*\)/ /"
}

src_compile() {
	if [[ "$CHROME_ORIGIN" != "LOCAL_SOURCE" ]] && [[ "$CHROME_ORIGIN" != "SERVER_SOURCE" ]]; then
		return
	fi

	check_cros_version

	cd "${CHROME_ROOT}"/src || die "Cannot chdir to ${CHROME_ROOT}/src"

	if use build_tests; then
		TEST_TARGETS="page_cycler_tests
			reliability_tests
			sync_integration_tests
			startup_tests
			ui_tests"
		if use x86; then  # Build PyAuto on x86 only.
			TEST_TARGETS="${TEST_TARGETS} pyautolib browser_tests"
		fi
		echo Building test targets: ${TEST_TARGETS}
	fi

	tc-export CXX CC AR AS RANLIB LD
	# HACK(raymes): If gold is present and is recent enough, we will use it.
	# In the (hopefully near) future, gold will be rolled as the default
	# system-wide linker and this logic can be removed.
	if use x86 && use gold ; then
		GOLD_CL=`$LD.gold --version | head -1 | sed \
			"s/.*cos_gg_v1_\([0-9]*\).*$/\1/g"`
		if [ $GOLD_CL -ge 44729 ] 2>/dev/null ; then
			einfo "Using gold from the following location: `which $LD.gold`"
			export CC="${CC} -fuse-ld=gold"
			export CXX="${CXX} -fuse-ld=gold"
			export LD="$LD.gold"
		else
			ewarn "gold was not found or is too old. Using GNU ld."
		fi
	fi

	if ! use chrome_debug; then
		# Override debug options for Chrome build.
		CXXFLAGS="$(strip_chrome_debug "${CXXFLAGS}")"
		CFLAGS="$(strip_chrome_debug "${CFLAGS}")"
		einfo "Stripped debug flags for Chrome build"
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
	fast_cp -a "${CHROME_ROOT}"/src/base/base_paths_linux.cc "${TEST_DIR}"/base

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
	if use chrome_internal && use chrome_pdf; then
		doexe "${FROM}"/libpdf.so
	fi
	exeopts -m4755	# setuid the sandbox
	newexe "${FROM}/chrome_sandbox" chrome-sandbox
	exeopts -m0755

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

	if use x86; then
		# Install Flash plugin.
		if use chrome_internal && [ -f "${FROM}/libgcflashplayer.so" ]; then
			# Install Flash from the binary drop.
			exeinto "${CHROME_DIR}"/plugins
			doexe "${FROM}/libgcflashplayer.so"
			doexe "${FROM}/plugin.vch"
		else
			if use chrome_internal && \
                [ "${CHROME_ORIGIN}" = "LOCAL_SOURCE" ]; then
				# Install Flash from the local source repository.
				exeinto "${CHROME_DIR}"/plugins
				doexe ${CHROME_ROOT}/src/third_party/adobe/flash/binaries/chromeos/libgcflashplayer.so
				doexe ${CHROME_ROOT}/src/third_party/adobe/flash/binaries/chromeos/plugin.vch
			else
				# Use Flash from www-plugins/adobe-flash package.
				dosym /opt/netscape/plugins/libflashplayer.so \
					"${CHROME_DIR}"/plugins/libflashplayer.so
			fi
		fi
	fi
}
