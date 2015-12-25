# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="2cf36a2574e4d6d262a1734e9b6d326f9bbcd4a8"
CROS_WORKON_TREE="0d5b17f27dc0af38076e0dc43f21131bfd8c1edf"
inherit cros-workon

CROS_WORKON_PROJECT="chromiumos/platform/factory"
CROS_WORKON_LOCALNAME="factory"
SRC_URI="gs://chromeos-localmirror/distfiles/overlord-deps-0.0.1.tar.gz"

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
