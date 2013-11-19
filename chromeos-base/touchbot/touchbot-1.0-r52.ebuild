# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="56c9eb969c0a932b32c68ef8b51d0d6b9b5e35da"
CROS_WORKON_TREE="f681e255424225ff7bafa3729d1eacbde1f09b11"
CROS_WORKON_PROJECT="chromiumos/platform/touchbot"
CROS_WORKON_LOCALNAME="touchbot"

inherit cros-workon distutils

DESCRIPTION="Suite of control scripts for the Touchbot"
HOMEPAGE="http://www.chromium.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
