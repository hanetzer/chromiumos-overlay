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
IUSE=""

RDEPEND="dev-lang/python"

DEPEND="
	${RDEPEND}"

# Create python package init files for top level test case dirs.
function touchInitPy() {
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

src_unpack() {
	local third_party="${CHROMEOS_ROOT}/src/third_party"
	elog "Using third_party: $third_party"
	mkdir -p "${S}"
	cp -fpru ${third_party}/autotest/files/{client,conmux,server,tko,utils,global_config.ini,shadow_config.ini} ${S} || die
}

src_configure() {
	cd ${S}
	touchInitPy client/tests client/site_tests
	touch __init__.py
	# Cleanup checked-in binaries that don't support the target architecture
	[[ ${E_MACHINE} == "" ]] && return 0;
	rm -fv $( scanelf -RmyBF%a . | grep -v -e ^${E_MACHINE} )
}

src_compile() {
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
	# Do not use sudo, it'll unset all your environment
	LOGNAME=${SUDO_USER} client/bin/autotest_client --quiet --client_test_setup=${TEST_LIST}
}

src_install() {
	insinto "/usr/local/autotest"
	doins -r "${S}"/*
}

pkg_postinst() {
  chown -R ${SUDO_UID}:${SUDO_GID} "${SYSROOT}/usr/local/autotest"
  chmod -R 755 "${SYSROOT}/usr/local/autotest"
}

