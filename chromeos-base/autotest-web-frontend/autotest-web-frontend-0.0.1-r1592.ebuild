# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="123d0d766e8ee80bdb7f39d303838bba8face8d6"
CROS_WORKON_TREE="24e9770e5e0f54485009ead9b2e037f378857bc5"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files
CROS_WORKON_SUBDIR_BLACKLIST=( "Documentation" "ExternalSource" "logs" "manifest-versions" "packages" "results" "site-packages" "containers")

inherit cros-workon cros-constants

DESCRIPTION="Autotest server web frontend"
HOMEPAGE="http://dev.chromium.org/chromium-os/testing"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	>chromeos-base/autotest-server-0.0.1-r1260
"

DEPEND=""

AUTOTEST_WORK="${WORKDIR}/autotest-work"
AUTOTEST_BASE="/autotest"

src_prepare() {
	mkdir -p "${AUTOTEST_WORK}"
	cp -fpru "${S}"/* "${AUTOTEST_WORK}/" &>/dev/null
	find "${AUTOTEST_WORK}" -name '*.pyc' -delete

	# Compile the frontend elements.
	"${AUTOTEST_WORK}"/utils/compile_gwt_clients.py -a -e"-Djava.util.prefs.userRoot=/tmp" || die
}

src_configure() {
	cros-workon_src_configure
}

src_install() {
	insinto "${AUTOTEST_BASE}/frontend/client/www"/
	doins -r "${AUTOTEST_WORK}/frontend/client/www"/*
}
