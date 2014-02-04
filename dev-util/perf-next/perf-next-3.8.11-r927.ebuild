# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/perf/perf-2.6.32.ebuild,v 1.1 2009/12/04 16:33:24 flameeyes Exp $

EAPI=4
CROS_WORKON_COMMIT="febacb61a98527a75b122d11a1803dd6f6f0ffd7"
CROS_WORKON_TREE="fc9c076609bd1d770f1c2a5e9c8819a1ab431543"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel-next"
CROS_WORKON_LOCALNAME="kernel-next"

inherit cros-workon cros-perf

KEYWORDS="*"
RDEPEND="!dev-util/perf"
DEPEND="${RDEPEND}
	${DEPEND}"


