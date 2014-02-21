# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="435c7d9540f2e9c6b8ce2eea6e237bafc7eea483"
CROS_WORKON_TREE="5911895751f89762930e5897b6fd0bc7840fac62"
CROS_WORKON_PROJECT="chromiumos/platform/wireless_automation"

inherit cros-workon python

DESCRIPTION="Wireless Automation library"
HOMEPAGE="http://www.chromium.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	dev-lang/python
"

# These are all either bash / python scripts.  No actual builds DEPS.
DEPEND=""

# Use default src_compile and src_install which use Makefile.

src_install() {
	insinto "$(python_get_sitedir)"
	doins -r wireless_automation
}
