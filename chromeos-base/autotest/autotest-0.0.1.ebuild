# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="Autotest build_autotest wrapper"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm"
IUSE="+autox buildcheck +xset +tpmtools"

# TODO(snanda): Remove xset dependence once power_LoadTest is switched over
# to use power manager
# TODO(semenzato): tpm-tools is included for hardware_TpmFirmware (and at this
# time only one binary is used, tpm_takeownership).  Once we have a testing
# image, a better way would be to add tpm-tools to the image.
RDEPEND="
  dev-cpp/gtest
  dev-lang/python
  autox? ( chromeos-base/autox )
  xset? ( x11-apps/xset )
  tpmtools? ( app-crypt/tpm-tools )
  "

DEPEND="
	${RDEPEND}"

export PORTAGE_QUIET=1

# Ensure the configures run by autotest pick up the right config.site
export CONFIG_SITE=/usr/share/config.site

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
}

function copy_src() {
	local dst=$1
	local autotest_files="${CHROMEOS_ROOT}/src/third_party/autotest/files"
	mkdir -p "${dst}"
	cp -fpru "${autotest_files}"/{client,conmux,server,tko,utils} ${dst} || die
	cp -fpru "${autotest_files}"/shadow_config.ini ${dst} || die
	sed "/^enable_server_prebuild/d" "${autotest_files}"/global_config.ini > \
		${dst}/global_config.ini
}

src_configure() {
	copy_src "${S}"
	cd "${S}"
	touch_init_py client/tests client/site_tests
	touch __init__.py
	# Cleanup checked-in binaries that don't support the target architecture
	[[ ${E_MACHINE} == "" ]] && return 0;
	rm -fv $( scanelf -RmyBF%a . | grep -v -e ^${E_MACHINE} )
}

src_compile() {
	setup_cross_toolchain

	# Do not use sudo, it'll unset all your environment
	LOGNAME=${SUDO_USER} \
		client/bin/autotest_client --quiet --client_test_setup=${TEST_LIST} \
		|| ! use buildcheck || die "Tests failed to build."
	# Cleanup some temp files after compiling
	find . -name '*.[ado]' -delete
}

src_install() {
	insinto "/usr/local/autotest"
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

	setup_ssh
	cd "${BUILD_STAGE}"

	setup_cross_toolchain

	local timestamp=$(date +%Y-%m-%d-%H.%M.%S)
	# Do not use sudo, it'll unset all your environment
	LOGNAME=${SUDO_USER} ./server/autoserv -r /tmp/results.${timestamp} \
		${AUTOSERV_ARGS}
	teardown_ssh
}

