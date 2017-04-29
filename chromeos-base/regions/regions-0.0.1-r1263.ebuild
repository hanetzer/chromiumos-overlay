# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="4ca5602b59e1cf06ce97049615d3b460a4c80353"
CROS_WORKON_TREE="9a6609e652846f3cf5920be5daed4887fedf740a"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_DESTDIR="${S}"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="regions"

inherit cros-workon

DESCRIPTION="Chromium OS Region Data"
HOMEPAGE="http://src.chromium.org"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

# 'jq' allows command line tools to access the JSON database.
RDEPEND="app-misc/jq"
DEPEND=""

src_unpack() {
	cros-workon_src_unpack
	S+="/regions"
}

src_compile() {
	./regions.py --format=json --output "${WORKDIR}/cros-regions.json"
}

src_test() {
	./regions_unittest.py
}

src_install() {
	dobin cros_region_data

	insinto /usr/share/misc
	doins "${WORKDIR}/cros-regions.json"
}
