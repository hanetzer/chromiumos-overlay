# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/perf/perf-2.6.32.ebuild,v 1.1 2009/12/04 16:33:24 flameeyes Exp $

EAPI=4
CROS_WORKON_COMMIT="22a97d99aca8bd2dfeb313292b1fe2c7883243c5"
CROS_WORKON_TREE="b6330fd3a8f2d25044c7685d440db3b088715478"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel"
CROS_WORKON_LOCALNAME="kernel/files"

inherit cros-workon cros-perf

KEYWORDS="*"
RDEPEND="!dev-util/perf-next"
DEPEND="${RDEPEND}
	${DEPEND}"


