# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="Build unit tests wrapper"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"

src_unpack() {
	# Copy over platform source to build tests
	local platform_dir="${CHROMEOS_ROOT}/src/platform"
	# Symbolic link for third-party for includes from other packages
	local third_party_dir="${CHROMEOS_ROOT}/src/third_party"  # For includes

	mkdir -p "${S}"
	# TODO(sosa@chromium.org) - Only copy packages we need for building tests
	cp -rfpu "$platform_dir" "${S}/platform"
	ln -s "${third_party_dir}" "${S}/third_party"
}

src_compile() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	export CCFLAGS="$CFLAGS"

	# |TEST_DIRS| must be defined by the caller - usually build_tests.sh
	mkdir -p "${S}/tests"
	for i in ${TEST_DIRS}
	do
		elog "building platform/$i"
		cd "platform/${i}"
		OUT_DIR="${S}/tests" ./make_tests.sh || die "Could not build tests for ${i}"
		cd -
	done

	elog "All tests built."
}

src_install() {
	insinto "/tests"
	insopts "-m0755 "
	doins "${S}/tests"/*
}
