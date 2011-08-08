# Copyright 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit toolchain-funcs

DESCRIPTION="Utility for manipulating firmware ROM mapping data structure"
HOMEPAGE="http://flashmap.googlecode.com"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${PN}-${PVR}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86"

# Disable unit testing for now because one of the test cases for detecting
# buffer overflow causes emake to fail when fmap_test is run.
# RESTRICT="test" will override FEATURES="test" and will also cause
# src_test() to be ignored by relevant scripts.
RESTRICT="test"
FEATURES="test"

# By default, ${S} only uses package name and version, e.g. flashmap-1.0.
# Since we package it with the revision from SVN appended at the end (-rN), we
# need to update ${S} so that it knows which directory to cd into after
# extracting the tarball.
S=${WORKDIR}/${PF}

src_compile() {
	emake CC="$(tc-getCC)" || die
}

src_test() {
	# default "test" target uses lcov, so "test_only" was added to only
	# build and run the test without generating coverage statistics
	emake CC="$(tc-getCC)" test_only || die
}

src_install() {
	dosbin fmap_{csum,decode,encode} || die
}
