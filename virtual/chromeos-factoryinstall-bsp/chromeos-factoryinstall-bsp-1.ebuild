# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

DESCRIPTION="Generic ebuild which satisifies
virtual/chromeos-factoryinstall-bsp. This is a direct dependency of
chromeos-base/chromeos-installshim, but is expected to be overridden
in an overlay for each specialized board. A typical non-generic
implementation will install any board-specific factory install related
files and executables which are not suitable for inclusion in a generic
board overlay."
HOMEPAGE="http://src.chromium.org"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""
