# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="fbe3562122b9165ce3d961ca25a1c8eb5ab7ed18"
CROS_WORKON_TREE="92d0aaf8a2f062dbdda6dbe78cf509a0972fd03f"
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
