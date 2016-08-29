# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="84fee7cba4f30b27b1e81833bd4b4e0231c20833"
CROS_WORKON_TREE="d50e6142e9a21390159a3f0243e0d9734b640e1d"
CROS_WORKON_PROJECT="chromiumos/platform/factory"
CROS_WORKON_LOCALNAME="factory"
SRC_URI="gs://chromeos-localmirror/distfiles/overlord-deps-0.0.3.tar.gz"

inherit cros-workon

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
