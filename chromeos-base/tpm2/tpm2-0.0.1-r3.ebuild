# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="752b695bc7e19760a815dce5ed64051895e52d23"
CROS_WORKON_TREE="72ac70fc936aeac19eedf6de0119fed760b9f421"
CROS_WORKON_PROJECT="chromiumos/third_party/tpm2"
CROS_WORKON_LOCALNAME="../third_party/tpm2"

inherit cros-workon

DESCRIPTION="TPM2.0 library"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

DEPEND="dev-libs/openssl"

src_compile() {
	emake
}

src_install() {
	dolib.a build/libtpm2.a
}
