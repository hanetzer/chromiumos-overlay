# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit cros-binary

DESCRIPTION="NVFlash tool (binary distribution)"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="tegra-local-bins"

DEPEND=""
RDEPEND=""

if use tegra-local-bins; then
	URI_BASE="file://"
else
	URI_BASE="ssh://tegra2-private@git.chromium.org:6222/home/tegra2-private"
fi
CROS_BINARY_URI="${URI_BASE}/${CATEGORY}/${PN}/${P}.tbz2"
CROS_BINARY_SUM="13bd3276e7914be1cfc05eb0349a32fa7a68a587"
