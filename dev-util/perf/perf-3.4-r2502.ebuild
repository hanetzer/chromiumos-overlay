# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/perf/perf-2.6.32.ebuild,v 1.1 2009/12/04 16:33:24 flameeyes Exp $

EAPI=4
CROS_WORKON_COMMIT="e20e879e1a238a1a9b46b77326b0a2ecf7f3ee02"
CROS_WORKON_TREE="9cc055deb7853df465218a3667e4aee75810c39f"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel"
CROS_WORKON_LOCALNAME="kernel/files"

inherit cros-workon cros-perf

KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
RDEPEND="!dev-util/perf-next"
DEPEND="${RDEPEND}
	${DEPEND}"


