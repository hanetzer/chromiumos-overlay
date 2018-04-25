# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT=("a2067994ce45f7ef3bb69b49b6ba1bbb1541e72a" "d0c573bc579068f3f3ce6fec777870f4f94e7ddf")
CROS_WORKON_TREE=("e7db41bbcb3b4f82fbdd8e9997a9363e6d960a8f" "4d440f79ebec3ea021858f30ef23c33498bd3264")
CROS_WORKON_PROJECT=(
	"chromiumos/platform/tast-tests"
	"chromiumos/platform/tast"
)
CROS_WORKON_LOCALNAME=(
	"tast-tests"
	"tast"
)
CROS_WORKON_DESTDIR=(
	"${S}"
	"${S}/tast-base"
)
# TODO(derat): Delete this hack after https://crbug.com/812032 is addressed.
CROS_GO_WORKSPACE="${S}:${S}/tast-base"

CROS_GO_TEST=(
	# Test support packages that live above remote/bundles/.
	"chromiumos/tast/remote/..."
)

inherit cros-workon tast-bundle

DESCRIPTION="Bundle of remote integration tests for Chrome OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/tast-tests/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
