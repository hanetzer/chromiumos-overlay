# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/perf/perf-2.6.32.ebuild,v 1.1 2009/12/04 16:33:24 flameeyes Exp $

EAPI=4
CROS_WORKON_COMMIT="748eee452089cd436a79cf3caace3db16b8cc10b"
CROS_WORKON_TREE="65705ba3a9e7ea4d35f19435752f6e895cd1a34d"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel"
CROS_WORKON_LOCALNAME="kernel/files"

inherit cros-workon cros-perf

KEYWORDS="amd64 arm x86"
RDEPEND="!dev-util/perf-next"
DEPEND="${RDEPEND}
	${DEPEND}"


