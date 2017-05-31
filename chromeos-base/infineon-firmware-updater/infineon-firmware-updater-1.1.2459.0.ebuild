# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI="5"

inherit eutils toolchain-funcs

DESCRIPTIION="Infineon TPM firmware updater"
SRC_URI="gs://chromeos-localmirror/distfiles/${P}.tar.gz"

LICENSE="BSD-Infineon LICENSE.infineon-firmware-updater-TCG"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	chromeos-base/infineon-firmware
	dev-libs/openssl
"

DEPEND="${RDEPEND}"

S="${WORKDIR}"

src_prepare() {
	epatch "${FILESDIR}"/makefile-fixes.patch
}

src_configure() {
	tc-export AR CC
}

src_compile() {
	emake -C TPMFactoryUpd
}

src_install() {
	newsbin TPMFactoryUpd/TPMFactoryUpd infineon-firmware-updater
}
