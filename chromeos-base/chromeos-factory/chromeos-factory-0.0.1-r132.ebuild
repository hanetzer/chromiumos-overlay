# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT=b15ae46e1ad46f06f74a17e6792e87feac030bd4
CROS_WORKON_TREE="8de6ba9f5ddcdc9c8bacb432204e4b79474e55d1"

EAPI=4
CROS_WORKON_PROJECT="chromiumos/platform/factory"

inherit cros-workon
inherit cros-binary
inherit python

DESCRIPTION="Chrome OS Factory Tools and Data"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

DEPEND=""
RDEPEND="!chromeos-base/chromeos-factorytools
	 dev-lang/python
         dev-python/netifaces
	 >=chromeos-base/vpd-0.0.1-r11"

CROS_WORKON_LOCALNAME="factory"

TARGET_DIR="/usr/local/factory"

CROS_BINARY_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/closure-library-20111110-r1376.tar.bz2"
CROS_BINARY_SUM="761af448631b4dd2339e01b04cb11140ad6d7706"

src_unpack() {
        cros-workon_src_unpack
        cros-binary_src_unpack
}

src_compile() {
        emake CLOSURE_LIB_ARCHIVE="${CROS_BINARY_STORE_DIR}/${CROS_BINARY_URI##*/}"
}

src_install() {
        emake DESTDIR="${D}" TARGET_DIR="${TARGET_DIR}" install
        dosym ../../../../local/factory/py $(python_get_sitedir)/cros/factory
        # For now, point 'custom' to suite_Factory.  TODO(jsalz): Actually
        # install files directly into custom as appropriate.
        dosym ../autotest/client/site_tests/suite_Factory ${TARGET_DIR}/custom

        # Directories used by Goofy.
        keepdir /var/factory/{,log,state,tests}
}
