# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="e2b074e8150e7ef8abc86ded0516b4e431c84e43"
CROS_WORKON_TREE="869301e2c3b7caee2d7d10481dd5a76b241d7457"
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
