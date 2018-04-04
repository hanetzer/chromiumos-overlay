# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT=("f89d1c428e4617cada61fe65a18cd99aa5b02459" "1e2e415d6cee0474a43c42cadc3501d82c437e14")
CROS_WORKON_TREE=("a4a66031aa3c304eb2ad77885ac7820f0db0a054" "97990f9a3a53938826bdd9842a3742f49eb7fc49")
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
