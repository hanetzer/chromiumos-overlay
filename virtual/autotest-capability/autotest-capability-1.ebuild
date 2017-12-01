# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

DESCRIPTION="Virtual package installing files define the capability of DUTs. We
run or skip test cases base on those capabilities. See README.md for details."
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="chromeos-base/autotest-capability-default"
