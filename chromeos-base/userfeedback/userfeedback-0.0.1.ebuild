# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"

DESCRIPTION="Log scripts used by userfeedback to report cros system information"
HOMEPAGE="http://www.chromium.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="arm x86"
IUSE=""

RDEPEND=""

DEPEND="${RDEPEND}"

src_install() {
	local feedback_dir="${CHROMEOS_ROOT}/src/platform/userfeedback"

	exeinto /usr/share/userfeedback/scripts
	doexe "${feedback_dir}"/scripts/*

	insinto /usr/share/userfeedback/etc
	doins "${feedback_dir}"/etc/*
}
