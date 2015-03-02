# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="7a148611b1ef242aa24afef9f00d31c11b8eb7cc"
CROS_WORKON_TREE="c776679ddd19e9e3bb85055f2d06a079b1e836a3"
CROS_WORKON_PROJECT="chromiumos/platform/webplot"

PYTHON_COMPAT=( python2_7 )
inherit cros-workon distutils-r1

DESCRIPTION="Web drawing tool for touch devices"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/webplot/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

src_unpack() {
	default
	cros-workon_src_unpack
	TARGET_PACKAGE="webplot/remote"
	TARGET_SRC_PATH="/mnt/host/source/src/platform"
	pushd "${S}/${TARGET_PACKAGE}"
	# Copy the real files/directories pointed to by symlinks.
	for f in *; do
		content=$(readlink $f)
		if [ -n "$content" ]; then
			rm -f $f
			SRC_SUBPATH=${content##.*\./}
			cp -pr "${TARGET_SRC_PATH}/${SRC_SUBPATH}" .
		fi
	done
	popd
}

src_install() {
	distutils-r1_src_install
	exeinto /usr/local/bin
	newexe webplot.sh webplot
}
