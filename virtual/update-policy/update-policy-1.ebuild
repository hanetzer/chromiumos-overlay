# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

DESCRIPTION="Virtual package installing the update engine's policy manager
configuration. Boards can override it to install their own configuration."
HOMEPAGE="http://src.chromium.org"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="cros_embedded"

RDEPEND="
	|| (
		!cros_embedded? ( chromeos-base/update-policy-chromeos )
		chromeos-base/update-policy-embedded
	)
"
DEPEND="${RDEPEND}"
