# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="Virtual for the perf tool."
SRC_URI=""

SLOT="0"
KEYWORDS="arm x86"
IUSE=""

RDEPEND="x86? ( dev-util/perf )
	arm? ( dev-util/perf-next )"
DEPEND=""
