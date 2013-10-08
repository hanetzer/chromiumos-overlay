# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=4
CROS_WORKON_COMMIT="bb1e9067625523c898845256ef19a2293e53e2f0"
CROS_WORKON_TREE="919914a67546be9880945df6030827519baa940e"
PYTHON_DEPEND="2"
CROS_WORKON_PROJECT="chromiumos/third_party/u-boot"
CROS_WORKON_LOCALNAME="u-boot"
CROS_WORKON_SUBDIR="files"

inherit cros-workon distutils

DESCRIPTION="Patman tool (from U-Boot) for sending patches upstream"
HOMEPAGE="http://www.denx.de/wiki/U-Boot"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="dev-python/setuptools"
RDEPEND=""

src_prepare() {
	cd tools/patman
	rm patman
	cp "${FILESDIR}/setup.py" .
	touch __init__.py

	distutils_src_prepare
}

src_compile() {
	cd tools/patman
	distutils_src_compile
}

src_install() {
	cd tools/patman
	dobin "${FILESDIR}/patman"
	distutils_src_install
}