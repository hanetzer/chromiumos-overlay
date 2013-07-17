# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/perf/perf-2.6.32.ebuild,v 1.1 2009/12/04 16:33:24 flameeyes Exp $

EAPI=4
CROS_WORKON_COMMIT="73f9c100c759b50748d05a78fa3dda6d1cd3cbdd"
CROS_WORKON_TREE="e5f17be82559b28d597a7b85545077d35354e837"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel-next"
CROS_WORKON_LOCALNAME="kernel-next"

inherit cros-workon cros-perf

KEYWORDS="amd64 arm x86"
RDEPEND="!dev-util/perf"
DEPEND="${RDEPEND}
	${DEPEND}"


