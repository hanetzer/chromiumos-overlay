# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
CROS_WORKON_COMMIT="e4f73a491e7c5a49403f3206416f9ed136667982"
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

