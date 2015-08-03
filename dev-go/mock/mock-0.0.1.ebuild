# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

# Disable cros-workon auto-uprev since this is an external package.
# Must manage commit/tree hashes manually.
CROS_WORKON_BLACKLIST="1"
CROS_WORKON_COMMIT="d581abfc04272f381d7a05e4b80163ea4e2b9447"
CROS_WORKON_TREE="71cd201d7c192c08ff55a08766cb8c8c44dea752"
CROS_WORKON_PROJECT="external/github.com/golang/mock"
CROS_WORKON_DESTDIR="${S}/src/github.com/golang/mock"

CROS_GO_PACKAGES=(
	"github.com/golang/mock/gomock"
	"github.com/golang/mock/mockgen/model"
)

CROS_GO_BINARIES=(
	"github.com/golang/mock/mockgen"
)

inherit cros-workon cros-go

DESCRIPTION="Mocking framework for the Go programming language"
HOMEPAGE="https://github.com/golang/mock"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND=""
RDEPEND=""
