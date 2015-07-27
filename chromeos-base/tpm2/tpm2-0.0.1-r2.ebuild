# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="9edfbac6a36e07e1a7ccb2260b6f65d97b45fef8"
CROS_WORKON_TREE="a56264a963332499a23bf648ed6b952620381e8e"
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
