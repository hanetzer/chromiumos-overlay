# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/perf/perf-2.6.32.ebuild,v 1.1 2009/12/04 16:33:24 flameeyes Exp $

EAPI=4
CROS_WORKON_COMMIT="ee9c4a37d36bfb9e57f76267d5b973cbd55cc9c1"
CROS_WORKON_TREE="a4befba352c821ee712e0055a0f7632dfee048ad"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel-next"
CROS_WORKON_LOCALNAME="kernel-next"

inherit cros-workon cros-perf

KEYWORDS="*"
RDEPEND="!dev-util/perf"
DEPEND="${RDEPEND}
	${DEPEND}"


