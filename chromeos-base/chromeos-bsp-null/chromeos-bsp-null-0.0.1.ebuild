# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="Empty (null) ebuild which satisifies virtual/chromeos-bsp.
This is a direct dependency of chromeos-base/chromeos, but is expected to
be overridden in an overlay for each specialized board.  A typical non-null
implementation will install any board-specific configuration files and
drivers which are not suitable for inclusion in a generic board overlay."

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""
PROVIDE="virtual/chromeos-bsp"

RDEPEND=""
DEPEND=""

#
# WARNING: Nothing should be added to this ebuild.  This ebuild is overriden
# in board specific overlays, via a base profile which specifies virtuals
#
