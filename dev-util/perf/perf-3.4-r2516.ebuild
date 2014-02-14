# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/perf/perf-2.6.32.ebuild,v 1.1 2009/12/04 16:33:24 flameeyes Exp $

EAPI=4
CROS_WORKON_COMMIT="64d8fb841f66673ceafba1e91a3063ab298c0305"
CROS_WORKON_TREE="e468346451b9858e97706a5e41e0690c638f85e6"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel"
CROS_WORKON_LOCALNAME="kernel/files"

inherit cros-workon cros-perf

KEYWORDS="*"
RDEPEND="!dev-util/perf-next"
DEPEND="${RDEPEND}
	${DEPEND}"


