# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/perf/perf-2.6.32.ebuild,v 1.1 2009/12/04 16:33:24 flameeyes Exp $

EAPI=4
CROS_WORKON_COMMIT="87e71d61ea4db76fcc84b4772be40c0699793e09"
CROS_WORKON_TREE="99e28f8efecfaa28056065e40990b75c2024bd86"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel-next"
CROS_WORKON_LOCALNAME="kernel-next"

inherit cros-workon cros-perf

KEYWORDS="*"
RDEPEND="!dev-util/perf"
DEPEND="${RDEPEND}
	${DEPEND}"


