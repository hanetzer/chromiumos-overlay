# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

DESCRIPTION="Intel(R) Dynamic Platform & Thermal Framework"
HOMEPAGE="https://01.org/dptf/"

LICENSE="Apache-2.0 GPL-2 BSD"
SLOT="0"
KEYWORDS="-* amd64 x86"

IUSE_KERNEL_VERS=(
	kernel-3_10
	kernel-3_18
)
IUSE="${IUSE_KERNEL_VERS[*]}"
REQUIRED_USE="?? ( ${IUSE_KERNEL_VERS[*]} )"

RDEPEND="
	kernel-3_10? ( sys-power/dptf-3_10 )
	kernel-3_18? ( sys-power/dptf )
"

# Add blockers so when migrating between USE flags, the old version gets
# unmerged automatically.
RDEPEND+="
	!kernel-3_10? ( !sys-power/dptf-3_10 )
	!kernel-3_18? ( !sys-power/dptf )
"

# Default to verison of DPTF that uses upstream drivers if none has been selected
RDEPEND_DEFAULT="sys-power/dptf"
