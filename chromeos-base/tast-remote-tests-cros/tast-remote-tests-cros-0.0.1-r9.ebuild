# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT=("22ca57344c9786cab9a9b156983bb4d231a056aa" "c9828b9da2b86bd812862ee6f67cfb1a12b39b5a")
CROS_WORKON_TREE=("423d9c758da7b6c3ba264413d79e245f1186f681" "2bf66d69a74ec98ea9d4c728865f53e99aa2d254")
CROS_WORKON_PROJECT=(
	"chromiumos/platform/tast"
	"chromiumos/platform/tast-tests"
)
CROS_WORKON_LOCALNAME=(
	"tast"
	"tast-tests"
)
CROS_WORKON_DESTDIR=(
	"${S}"
	"${S}/tast-tests"
)
# TODO(derat): Delete this hack after https://crbug.com/812032 is addressed.
CROS_GO_WORKSPACE="${S}:${S}/tast-tests"

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
