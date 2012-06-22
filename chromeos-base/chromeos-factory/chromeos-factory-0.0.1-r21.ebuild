# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="9338c0c106ab78adf8e07b0101193d6f22c769eb"
CROS_WORKON_TREE="497694a062414d2e91a8678898d5b1e811b16efc"

EAPI=4
CROS_WORKON_PROJECT="chromiumos/platform/factory"

inherit cros-workon
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
	 >=chromeos-base/vpd-0.0.1-r11"

CROS_WORKON_LOCALNAME="factory"

TARGET_DIR="/usr/local/factory"

doexescript() {
	local source="$1"
	local command=$(basename "${source%.*}")
	fperms 0755 ${TARGET_DIR}/$source
	dosym ./${source} ${TARGET_DIR}/$command
}

src_install() {
	insinto ${TARGET_DIR}/py
	doins py/*
	doexescript py/gooftool.py
	doexescript py/hwid_tool.py
	doexescript py/edid.py
	exeinto ${TARGET_DIR}/sh
	doexe sh/*
	insinto ${TARGET_DIR}/misc
	doins misc/*
	insinto $(python_get_sitedir)/cros
	doins py_pkg/cros/__init__.py
	dosym ${TARGET_DIR}/py $(python_get_sitedir)/cros/factory
}
