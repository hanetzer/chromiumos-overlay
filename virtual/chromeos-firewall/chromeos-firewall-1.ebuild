# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

DESCRIPTION="Chrome OS Firewall virtual package. This package will RDEPEND
on the actual package that installs the upstart scripts to configure the
firewall. Any board overlays that wish to change the firewall settings can
do so with their own virtual package and corresponding ebuild."
HOMEPAGE="http://src.chromium.org"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"

RDEPEND="chromeos-base/chromeos-firewall-init"