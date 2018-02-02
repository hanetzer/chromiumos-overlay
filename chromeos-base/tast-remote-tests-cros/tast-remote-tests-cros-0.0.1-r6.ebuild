# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="d6be583ee93c7a2bdb799df32209f50b4aed69cf"
CROS_WORKON_TREE="9e6d43a38990423059770bd4a41912825b2bc1f7"
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
