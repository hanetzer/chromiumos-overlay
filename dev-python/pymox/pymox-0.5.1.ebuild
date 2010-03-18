# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
inherit distutils
EAPI="2"

tarname="mox-${PV}"
DESCRIPTION="Mock object generator for python testing"
HOMEPAGE="http://code.google.com/p/pymox"
SRC_URI="http://pymox.googlecode.com/files/${tarname}.tar.gz"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64 x86 arm"

PYTHON_MODNAME="mox"

S=${WORKDIR}/${tarname}
