# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="7bbc9fdcf326e7bafd101eb431d64fc4746c865e"
inherit cros-workon

DESCRIPTION="Build chromeos crash handler"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="x86 arm"
IUSE="test"

RDEPEND="chromeos-base/google-breakpad"
DEPEND="${RDEPEND}"

src_compile() {
	tc-export CXX
	emake libcrash.so || die "compile failed."
}

src_test() {
	tc-export CXX
	emake tests || die "could not build tests"
	if ! use x86; then
	        echo Skipping unit tests on non-x86 platform
	else
	        for test in ./*_test; do
		        # Prefer libcrash in our directory over the
		        # one installed in /usr/lib.
		        LD_LIBRARY_PATH=$(pwd):${LD_LIBRARY_PATH} \
			    "${test}" ${GTEST_ARGS} || die "${test} failed"
		done
	fi
}

src_install() {
	into /usr
	dolib.so libcrash.so || die
}
