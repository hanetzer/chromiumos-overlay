# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
CROS_WORKON_COMMIT="6b8c3741d335d408bb7f7c458567c8c30a1d07a1"

inherit cros-workon

DESCRIPTION="Development utilities for ChromiumOS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="minimal"

CROS_WORKON_PROJECT="dev-util"
CROS_WORKON_LOCALNAME="dev"


RDEPEND="app-shells/bash
         app-portage/gentoolkit
         dev-lang/python
         dev-libs/shflags
         minimal? ( !chromeos-base/gmerge )
         "

DEPEND="${RDEPEND}"

src_install() {
	exeinto /usr/bin
	if use minimal; then
		doexe gmerge
		doexe stateful_update
	else
		doexe host/write_tegra_bios
	fi
}

