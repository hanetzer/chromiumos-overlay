# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs flag-o-matic

DESCRIPTION="Autotest scripts and tools"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~arm ~amd64"

# Ensure the configures run by autotest pick up the right config.site
export CONFIG_SITE=/usr/share/config.site
export AUTOTEST_SRC="${CHROMEOS_ROOT}/src/third_party/autotest/files"

src_unpack() {
	local dst="${WORKDIR}/${P}"
	mkdir -p "${dst}/client"
	mkdir -p "${dst}/server"
	cp -fpu "${AUTOTEST_SRC}"/client/* "${dst}/client" &>/dev/null
	cp -fpru "${AUTOTEST_SRC}"/client/{bin,common_lib,tools} "${dst}/client"
	cp -fpu "${AUTOTEST_SRC}"/server/* "${dst}/server" &>/dev/null
	cp -fpru "${AUTOTEST_SRC}"/server/{bin,control_segments,hosts} "${dst}/server"
	cp -fpru "${AUTOTEST_SRC}"/{conmux,tko,utils} "${dst}"
	cp -fpru "${AUTOTEST_SRC}"/shadow_config.ini "${dst}"
}

src_prepare() {
	sed "/^enable_server_prebuild/d" "${AUTOTEST_SRC}/global_config.ini" > \
		"${S}/global_config.ini"
}

src_install() {
	insinto /usr/local/autotest
	doins -r "${WORKDIR}/${P}"/*
}
