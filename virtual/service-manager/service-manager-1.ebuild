# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

DESCRIPTION="Generic ebuild which satisifies virtual/service-manager.
This is a direct dependency of chromeos-base/chromeos, but can
be overridden in an overlay for specialized boards.

To satisfy this virtual, a package should cause to be installed everything
required to bring the system up and start managing system services."
HOMEPAGE="http://src.chromium.org"

LICENSE=""
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
IUSE=""

RDEPEND="chromeos-base/chromeos-init"
DEPEND="${RDEPEND}"
