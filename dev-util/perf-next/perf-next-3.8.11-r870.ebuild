# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/perf/perf-2.6.32.ebuild,v 1.1 2009/12/04 16:33:24 flameeyes Exp $

EAPI=4
CROS_WORKON_COMMIT="403162e6e7229952e0c8b8e86d5b2eda09ab93e4"
CROS_WORKON_TREE="f481ac6000bdd9ea55e04d6d1f3d2baef9862835"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel-next"
CROS_WORKON_LOCALNAME="kernel-next"

inherit cros-workon cros-perf

KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
RDEPEND="!dev-util/perf"
DEPEND="${RDEPEND}
	${DEPEND}"


