# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/perf/perf-2.6.32.ebuild,v 1.1 2009/12/04 16:33:24 flameeyes Exp $

EAPI=4
CROS_WORKON_COMMIT="217b2de70ee1fd827e58402d41eb3ac6f33114f7"
CROS_WORKON_TREE="1402c2ad6f14d0a486dde634c2dfa6968493b7ca"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel"
CROS_WORKON_LOCALNAME="kernel/files"

inherit cros-workon cros-perf

KEYWORDS="*"
RDEPEND="!dev-util/perf-next"
DEPEND="${RDEPEND}
	${DEPEND}"


