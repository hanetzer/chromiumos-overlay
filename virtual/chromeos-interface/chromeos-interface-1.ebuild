# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

DESCRIPTION="Generic ebuild which satisifies virtual/chromeos-interface.
This is a direct dependency of chromeos-base/chromeos, but can
be overridden in an overlay for specialized boards.

To satisfy this virtual, a package should cause to be installed everything
a user would need to interact with the system locally."
HOMEPAGE="http://src.chromium.org"

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
IUSE="-content_shell -chromeless_tty"

RDEPEND="
	!chromeless_tty? (
		content_shell? ( chromeos-base/content_shell )
		!content_shell? (
			chromeos-base/chromeos-login
			chromeos-base/chromeos-chrome
		)
	)
	chromeless_tty? ( chromeos-base/tty1 )
"

DEPEND="${RDEPEND}"
