# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
CROS_WORKON_COMMIT="1f09a107cea3d5aacf51572cde12c56f1251141e"
CROS_WORKON_PROJECT="chromiumos/platform/dev-util"

inherit cros-workon

DESCRIPTION="A util for installing packages using the CrOS dev server"
HOMEPAGE="http://www.chromium.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

CROS_WORKON_LOCALNAME="dev"

RDEPEND="app-shells/bash
	dev-lang/python
	dev-libs/shflags
	sys-apps/portage"
DEPEND="${RDEPEND}"

src_install() {
	exeinto /usr/bin
	doexe gmerge
	doexe stateful_update
	insinto /etc/make.profile
	doins /usr/local/portage/chromiumos/profiles/targets/chromeos/*
}

