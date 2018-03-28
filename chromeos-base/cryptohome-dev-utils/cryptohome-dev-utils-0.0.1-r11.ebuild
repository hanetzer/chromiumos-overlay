# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT="0415e7bf95c1d09b63c903ae8fa6facda6c4de73"
CROS_WORKON_TREE=("5e90f79dec6430d855d27326141abc48491d5a63" "c2c90d8d3544dc7aead291af6d948dd37e19c527" "2879d4e7ab8b8818fbd9c9eaf75e54739e7bb22f")
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"
CROS_WORKON_INCREMENTAL_BUILD=1
# TODO(crbug.com/809389): Avoid directly including headers from other packages.
CROS_WORKON_SUBTREE="common-mk cryptohome secure_erase_file"

PLATFORM_SUBDIR="cryptohome"
PLATFORM_GYP_FILE="cryptohome-dev-utils.gyp"

inherit cros-workon platform

DESCRIPTION="Cryptohome developer and testing utilities for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/cryptohome"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="tpm tpm2"

REQUIRED_USE="tpm2? ( !tpm )"

RDEPEND="
	tpm? (
		app-crypt/trousers
	)
	tpm2? (
		chromeos-base/trunks
		chromeos-base/tpm_manager
		chromeos-base/attestation
	)
	chromeos-base/libbrillo:=
	chromeos-base/metrics
	chromeos-base/secure-erase-file
	dev-libs/openssl:=
	dev-libs/protobuf:=
"

DEPEND="${RDEPEND}"

src_install() {
	dosbin "${OUT}"/cryptohome-tpm-live-test
}
