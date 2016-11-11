# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit cros-constants git-2 toolchain-funcs

DESCRIPTION="Fuzzing library from LLVM"
HOMEPAGE="http://llvm.org/docs/LibFuzzer.html"
SRC_URI=""

LICENSE="UoI-NCSA"
SLOT="0/${PV}"
KEYWORDS="*"

src_unpack() {
	EGIT_REPO_URI="${CROS_GIT_HOST_URL}/chromiumos/third_party/llvm.git"
	EGIT_SOURCEDIR="${S}/"
	EGIT_PROJECT="llvm"
	EGIT_COMMIT="26a9873b72c6dbb425ae075fcf51caa9fc5e892b"
	git-2_src_unpack
}

src_configure() {
	:
}

v() {
	echo "$@"
	"$@" || die
}

src_compile() {
	v $(tc-getCXX) ${CPPFLAGS} ${CXXFLAGS} -Xclang-only=-fsanitize-coverage=0 -c -std=c++11 lib/Fuzzer/*.cpp -Ilib/Fuzzer
	v $(tc-getAR) cqD libFuzzer.a Fuzzer*.o
}

src_install() {
	dolib.a libFuzzer.a
}
