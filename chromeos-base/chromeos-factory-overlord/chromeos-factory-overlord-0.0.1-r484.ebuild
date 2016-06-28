# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="53cbbd572b28d3442a2479193f49d65b6e4e9867"
CROS_WORKON_TREE="488b1388d6501bbabd18d5fc0cb18806a6c379ac"
inherit cros-workon

CROS_WORKON_PROJECT="chromiumos/platform/factory"
CROS_WORKON_LOCALNAME="factory"
SRC_URI="gs://chromeos-localmirror/distfiles/overlord-deps-0.0.3.tar.gz"

DESCRIPTION="Overlord factory monitor"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="static"

RDEPEND=""
DEPEND="dev-lang/go"

src_unpack() {
	cros-workon_src_unpack

	mkdir -p factory/build
	cd factory/build
	unpack ${A}
}

src_compile() {
	emake -C go/src/overlord DEPS=false STATIC=$(usex static true false)
}

src_install() {
	dobin go/bin/overlordd
	dobin go/bin/ghost

	insinto /usr/share/overlord
	doins -r go/src/overlord/app
}
