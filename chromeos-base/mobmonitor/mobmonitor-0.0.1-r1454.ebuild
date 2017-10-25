# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="c7393a61aa4c24d064cfd31db71bea4b5b2d0074"
CROS_WORKON_TREE="4a0cedd1e93b1eab43dd22c6031a8b69a84d1573"
CROS_WORKON_PROJECT="chromiumos/chromite"
CROS_WORKON_LOCALNAME="../../chromite"

inherit cros-workon python

DESCRIPTION="Service health checking tool for Moblab"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	>=chromeos-base/chromite-0.0.2
"

DEPEND=""

src_install() {
	MOBMONITOR_SITEDIR="$(python_get_sitedir)/chromite/mobmonitor"

	# Copy the mobmonitor source.
	insinto "${MOBMONITOR_SITEDIR}"
	doins -r "${S}/mobmonitor"/*


	# Clean up unwanted files.
	cd "${D}/${MOBMONITOR_SITEDIR}"
	find '(' -name '*.pyc' -o -name '*unittest.py' ')' -delete

	# Create executable Mob* Monitor scripts.
	newbin "${MOBMONITOR_SITEDIR}/scripts/mobmonitor.py" "mobmonitor"
	newbin "${MOBMONITOR_SITEDIR}/scripts/mobmoncli.py" "mobmoncli"

	# Create the Mob* Monitor check file directory.
	dodir "/etc/mobmonitor/checkfiles/"

	# Copy the static content for the web interface.
	insinto "/etc/mobmonitor/static/"
	doins -r "${S}/mobmonitor/static/"*
}
