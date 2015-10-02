# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

CROS_WORKON_COMMIT="0280326e5bd212fcfbe3696e113730045debae74"
CROS_WORKON_TREE="7e6af1bd8b9e107627e32a60977ed1970acac055"
CROS_WORKON_PROJECT="chromiumos/platform/go-seccomp"
CROS_WORKON_LOCALNAME="../platform/go-seccomp"

CROS_GO_PACKAGES=(
	"chromiumos/seccomp"
)

inherit cros-workon cros-go

DESCRIPTION="Go support for Chromium OS Seccomp-BPF policy files"
HOMEPAGE="http://chromium.org/chromium-os/developer-guide/chromium-os-sandboxing"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND=""
RDEPEND=""
