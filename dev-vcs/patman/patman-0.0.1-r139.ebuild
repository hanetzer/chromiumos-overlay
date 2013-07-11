# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=4
CROS_WORKON_COMMIT="72dfaa0199b5c782fcef2244574085200f2a9015"
CROS_WORKON_TREE="03916ee093de8f4b472e7d1e529aef7b6a4f67b7"
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