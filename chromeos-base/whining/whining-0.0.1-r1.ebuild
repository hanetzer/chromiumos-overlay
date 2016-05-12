# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="c4912baf54bc3c064f3d2d44a1907545f2a1795e"
CROS_WORKON_TREE="ff804ee88f1d783a169b5a6d1069168dd450b9b5"
CROS_WORKON_PROJECT="chromiumos/third_party/whining"
CROS_WORKON_LOCALNAME=../third_party/whining

inherit cros-workon cros-constants

DESCRIPTION="Whining matrix"
HOMEPAGE="http://dev.chromium.org/chromium-os/testing"
SRC_URI=""
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	dev-python/bottle
"

DEPEND=""

WHINING_WORK="${WORKDIR}/whining-work"
WHINING_BASE="/whining"

src_prepare() {
	mkdir -p "${WHINING_WORK}"
	cp -fpru "${S}"/* "${WHINING_WORK}/" &>/dev/null
	find "${WHINING_WORK}" -name '*.pyc' -delete
}

src_install() {
	insinto "${WHINING_BASE}"
	doins -r "${WHINING_WORK}"/*
	doins "${FILESDIR}"/apache-conf
	doins "${FILESDIR}"/config.ini

	insinto /etc/init
	doins "${FILESDIR}"/whining_setup.conf
}
