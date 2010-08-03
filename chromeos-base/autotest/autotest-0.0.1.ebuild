# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs flag-o-matic

DESCRIPTION="Autotest build_autotest wrapper"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm"
IUSE="+autox buildcheck +xset +tpmtools opengles hardened"

# TODO(snanda): Remove xset dependence once power_LoadTest is switched over
# to use power manager
# TODO(semenzato): tpm-tools is included for hardware_TpmFirmware (and at this
# time only one binary is used, tpm_takeownership).  Once we have a testing
# image, a better way would be to add tpm-tools to the image.
RDEPEND="
  chromeos-base/crash-dumper
  chromeos-base/flimflam
  dev-cpp/gtest
  dev-lang/python
  autox? ( chromeos-base/autox )
  xset? ( x11-apps/xset )
  tpmtools? ( app-crypt/tpm-tools )
  "

# Needed for audiovideo_PlaybackRecordSemiAuto
RDEPEND="${RDEPEND}
  media-sound/pulseaudio
"

# Needed for deps/chrome_test (used in desktopui_BrowserTest and
# desktopUI_UITest)
RDEPEND="${RDEPEND}
  chromeos-base/chromeos-chrome
"

# Needed for deps/ibusclient (used in desktopui_IBusTest)
RDEPEND="${RDEPEND}
  app-i18n/ibus
  dev-libs/glib
  sys-apps/dbus
"

# Needed for deps/glbench (used in graphics_GLBench, graphics_TearTest, and
# graphics_WindowManagerGraphicsCapture)
RDEPEND="${RDEPEND}
  virtual/opengl
  opengles? ( virtual/opengles )
"

# Needed for platform_MiniJailRootCapabilities
RDEPEND="${RDEPEND}
  sys-libs/libcap
"

DEPEND="
	${RDEPEND}"

export PORTAGE_QUIET=1

# Ensure the configures run by autotest pick up the right config.site
export CONFIG_SITE=/usr/share/config.site
export AUTOTEST_SRC="${CHROMEOS_ROOT}/src/third_party/autotest/files"

# Create python package init files for top level test case dirs.
function touch_init_py() {
	local dirs=${1}
	for base_dir in $dirs
	do
		local sub_dirs="$(find ${base_dir} -maxdepth 1 -type d)"
		for sub_dir in ${sub_dirs}
		do
			touch ${sub_dir}/__init__.py
		done
		touch ${base_dir}/__init__.py
	done
}

function setup_ssh() {
	eval $(ssh-agent) > /dev/null
	ssh-add \
		${CHROMEOS_ROOT}/src/scripts/mod_for_test_scripts/ssh_keys/testing_rsa
}

function teardown_ssh() {
	ssh-agent -k > /dev/null
}

function setup_cross_toolchain() {
	if tc-is-cross-compiler ; then
		tc-getCC
		tc-getCXX
		tc-getAR
		tc-getRANLIB
		tc-getLD
		tc-getNM
		tc-getSTRIP
		export PKG_CONFIG_PATH="${ROOT}/usr/lib/pkgconfig/"
		export CCFLAGS="$CFLAGS"
	fi

	# TODO(fes): Check for /etc/hardened for now instead of the hardened
	# use flag because we aren't enabling hardened on the target board.
	# Rather, right now we're using hardened only during toolchain compile.
	# Various tests/etc. use %ebx in here, so we have to turn off PIE when
	# using the hardened compiler
	if use x86 ; then
		if use hardened ; then
			#CC="${CC} -nopie"
			append-flags -nopie
		fi
	fi
}

function copy_src() {
	local dst=$1
	mkdir -p "${dst}"
	rsync -rplv --exclude='.svn' --delete --delete-excluded \
	  "${AUTOTEST_SRC}"/{client,conmux,server,tko,utils} "${dst}" || die
	cp -fpru "${AUTOTEST_SRC}/shadow_config.ini" "${dst}" || die
}

src_configure() {
	copy_src "${S}"
	sed "/^enable_server_prebuild/d" "${AUTOTEST_SRC}/global_config.ini" > \
		"${S}/global_config.ini"
	cd "${S}"
	touch_init_py client/tests client/site_tests
	touch __init__.py
	# Cleanup checked-in binaries that don't support the target architecture.
	echo E_MACHINE: $E_MACHINE
	[[ ${E_MACHINE} == "" ]] && return 0;
	date
	echo Removing elf files for unsupported architectures...
	rm -fv $( scanelf -RmyBF%a ./client/site_tests | grep -v -e ^${E_MACHINE} )
	echo Removal done.
	date
}

src_compile() {
	setup_cross_toolchain

	if use opengles ; then
		graphics_backend=OPENGLES
	else
		graphics_backend=OPENGL
	fi

	# Do not use sudo, it'll unset all your environment
	GRAPHICS_BACKEND="$graphics_backend" LOGNAME=${SUDO_USER} \
		client/bin/autotest_client --quiet --client_test_setup=${TEST_LIST} \
		|| ! use buildcheck || die "Tests failed to build."
	# Cleanup some temp files after compiling
	find . -name '*.[ado]' -delete
}

src_install() {
	insinto /usr/local/autotest
	doins -r "${S}"/*
}

pkg_postinst() {
	chown -R ${SUDO_UID}:${SUDO_GID} "${SYSROOT}/usr/local/autotest"
	chmod -R 755 "${SYSROOT}/usr/local/autotest"
}

# Define a directory which will not be cleaned by portage automatically. So we
# could achieve incremental build between two autoserv runs.
BUILD_STAGE=${PORTAGE_BUILDDIR}/staging

src_test() {
	local third_party="${CHROMEOS_ROOT}/src/third_party"
	copy_src "${BUILD_STAGE}"
	cp -fpru "${AUTOTEST_SRC}/global_config.ini" "${BUILD_STAGE}"

	sudo chown -R ${SUDO_UID}:${SUDO_GID} "${BUILD_STAGE}"
	sudo chmod -R 755 "${BUILD_STAGE}"

	setup_ssh
	cd "${BUILD_STAGE}"

	setup_cross_toolchain

	local args=()
	if [[ -n ${AUTOSERV_TEST_ARGS} ]]; then
		args=("-a" "${AUTOSERV_TEST_ARGS}")
	fi

	local timestamp=$(date +%Y-%m-%d-%H.%M.%S)
	# Do not use sudo, it'll unset all your environment
	LOGNAME=${SUDO_USER} ./server/autoserv -r /tmp/results.${timestamp} \
		${AUTOSERV_ARGS} "${args[@]}"
	teardown_ssh
}

