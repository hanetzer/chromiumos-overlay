# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

DESCRIPTION="Binary installer for crosvm"
SRC_URI="gs://chromeos-localmirror/distfiles/crosvm-amd64-${PV}.tbz2"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="-* amd64"
IUSE=""
RESTRICT="strip"

RDEPEND="
	!chromeos-base/crosvm
	chromeos-base/minijail
"
DEPEND="${RDEPEND}"

S="${WORKDIR}"

src_install() {
	insinto /
	doins -r *
	fperms a+rx /usr/bin/crosvm
}
