# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/perf/perf-2.6.32.ebuild,v 1.1 2009/12/04 16:33:24 flameeyes Exp $

EAPI=4
CROS_WORKON_COMMIT="7a9fe821d8492bb0198ba589b3634a19668cca22"
CROS_WORKON_TREE="06b547e7b5f968601e0613526b4ddeb72dabeeb0"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel-next"
CROS_WORKON_LOCALNAME="kernel-next"

inherit cros-workon cros-perf

KEYWORDS="*"
RDEPEND="!dev-util/perf"
DEPEND="${RDEPEND}
	${DEPEND}"


