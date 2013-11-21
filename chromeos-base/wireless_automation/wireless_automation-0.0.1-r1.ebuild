# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="ecf7520b961b329c1436cff5255d7acdf773b46b"
CROS_WORKON_TREE="8b599adbb19046ef82df161203f2c469e0ce3255"
CROS_WORKON_PROJECT="chromiumos/platform/wireless_automation"

inherit cros-workon python

DESCRIPTION="Wireless Automation library"
HOMEPAGE="http://www.chromium.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"

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
