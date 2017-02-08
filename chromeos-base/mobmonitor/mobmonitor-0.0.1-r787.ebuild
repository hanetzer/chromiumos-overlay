# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="7adb3340320a46c3cebfaadf8676a25d35e6730d"
CROS_WORKON_TREE="c9548bed4e9f72f5f0bc6169f5123746f47f4d6c"
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
