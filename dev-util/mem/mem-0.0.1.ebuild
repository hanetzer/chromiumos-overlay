# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=4
PYTHON_DEPEND="2"

inherit distutils

DESCRIPTION="Utils for reading/writing to /dev/mem"
HOMEPAGE="http://chromium.org"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
IUSE=""

DEPEND="dev-python/setuptools"
RDEPEND=""

src_unpack() {
	S=${WORKDIR}
	cp -r "${FILESDIR}/"* "${S}" || die
}
