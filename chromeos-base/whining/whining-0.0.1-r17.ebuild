# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="c325abd3eff318af433a1a5667f5d2745f893945"
CROS_WORKON_TREE="ffa1fe991f4b24d82eddf3385f3aabcdf98e89e3"
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
