# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="b911d71124769d6201da19ef08fbf347a59a22cd"
CROS_WORKON_TREE="89dd4d2064c8531b38d1283ee92a5be03a255632"
CROS_WORKON_PROJECT="chromiumos/platform/tast-tests"
CROS_WORKON_LOCALNAME="tast-tests"

# Test support packages that live above remote/bundles/.
CROS_GO_TEST=(
	"chromiumos/tast/remote/..."
)

inherit cros-workon tast-bundle

DESCRIPTION="Bundle of remote integration tests for Chrome OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/tast-tests/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
