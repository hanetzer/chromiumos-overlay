# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/perf/perf-2.6.32.ebuild,v 1.1 2009/12/04 16:33:24 flameeyes Exp $

EAPI=4
CROS_WORKON_COMMIT="90d2546ea00547e815bb145cf158e3a5b8bd86d5"
CROS_WORKON_TREE="54eeb34f198374a9d8596cbe45fa23e26c2476d0"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel-next"
CROS_WORKON_LOCALNAME="kernel-next"

inherit cros-workon cros-perf

KEYWORDS="amd64 arm x86"
RDEPEND="!dev-util/perf"
DEPEND="${RDEPEND}
	${DEPEND}"


