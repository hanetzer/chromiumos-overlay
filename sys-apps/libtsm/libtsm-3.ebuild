# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Terminal Emulator State Machine"
HOMEPAGE="http://cgit.freedesktop.org/~dvdhrm/libtsm"
SRC_URI="http://www.freedesktop.org/software/kmscon/releases/${P}.tar.xz"

LICENSE="LGPL-2.1 MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="!!=sys-apps/kmscon-7"
RDEPEND="${DEPEND}"
