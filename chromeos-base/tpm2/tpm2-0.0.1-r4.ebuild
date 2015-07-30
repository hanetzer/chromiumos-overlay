# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="764a7d67fcb388409711199e014f60a0e960944d"
CROS_WORKON_TREE="8ae077623e63d6a7b08e3de42e3488bc5b7fa663"
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
