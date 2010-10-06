# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="8bc705cd133a281ad4c31cb24bfe20a8a14e8e92"

inherit toolchain-funcs flag-o-matic cros-workon

DESCRIPTION="Autotest scripts and tools"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm amd64"

RDEPEND="dev-lang/python"
DEPEND="${RDEPEND}"

# Ensure the configures run by autotest pick up the right config.site
export CONFIG_SITE=/usr/share/config.site

CROS_WORKON_PROJECT=autotest
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

AUTOTEST_WORK="${WORKDIR}/autotest-work"

src_prepare() {
	mkdir -p "${AUTOTEST_WORK}/client"
	mkdir -p "${AUTOTEST_WORK}/server"
	cp -fpu "${S}"/client/* "${AUTOTEST_WORK}/client" &>/dev/null
	cp -fpru "${S}"/client/{bin,common_lib,tools} "${AUTOTEST_WORK}/client"
	cp -fpu "${S}"/server/* "${AUTOTEST_WORK}/server" &>/dev/null
	cp -fpru "${S}"/server/{bin,control_segments,hosts} "${AUTOTEST_WORK}/server"
	cp -fpru "${S}"/{conmux,tko,utils} "${AUTOTEST_WORK}"
	cp -fpru "${S}"/shadow_config.ini "${AUTOTEST_WORK}"

	sed "/^enable_server_prebuild/d" "${S}/global_config.ini" > \
		"${AUTOTEST_WORK}/global_config.ini"
}

src_install() {
	insinto /usr/local/autotest
	doins -r "${AUTOTEST_WORK}"/*

	# base __init__.py
	touch "${D}"/usr/local/autotest/__init__.py

	TESTDIRS="
		client/tests client/site_tests
		client/config client/deps client/profilers
		server/tests server/site_tests"

	# also pre-create the test dirs
	for dir in ${TESTDIRS}; do
		mkdir "${D}/usr/local/autotest/${dir}"
		touch "${D}/usr/local/autotest/${dir}"/.keep
	done

	# TODO: This should be more selective
	chmod -R a+x "${D}"/usr/local/autotest

	# setup stuff needed for read/write operation
	dodir "/usr/local/autotest/packages"
	chmod a+wx "${D}/usr/local/autotest/packages"

	dodir "/usr/local/autotest/client/packages"
	chmod a+wx "${D}/usr/local/autotest/client/packages"

	dodir "/usr/local/autotest/server/tmp"
	chmod a+wx "${D}/usr/local/autotest/server/tmp"
}
