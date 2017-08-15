#
# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# $Header:$
#

EAPI=4
CROS_WORKON_COMMIT="c050715684a5dde3a4fc818f3de816a407fdb2de"
CROS_WORKON_TREE="512284c409adda67e4bafc179a57a19df48889e3"
CROS_WORKON_PROJECT="chromiumos/platform/punybench"
CROS_WORKON_LOCALNAME="../platform/punybench"
inherit cros-constants cros-workon toolchain-funcs

DESCRIPTION="A set of file system microbenchmarks"
HOMEPAGE="${CROS_GIT_HOST_URL}/${CROS_WORKON_PROJECT}"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

##DEPEND="sys-libs/ncurses"

src_compile() {
	# Clang generates deprecated symbol "mcount", by default, on arm
	# architectures, resulting in unresolved symbol error. Using
	#'-meabi gnu' causes clang to generate an alternative symbol instead.
	case ${ARCH} in
	arm)
		if tc-is-clang ; then
			append-flags "-meabi gnu"
		fi
		;;
	esac
	tc-export CC
	if [ "${ARCH}" == "amd64" ]; then
		PUNYARCH="x86_64"
	else
		PUNYARCH=${ARCH}
	fi
	emake BOARD="${PUNYARCH}"
}

src_prepare() {
	filter_clang_syntax
	cros-workon_src_prepare
}

src_configure() {
	cros-workon_src_configure
}

src_install() {
	emake install BOARD="${PUNYARCH}" DESTDIR="${D}"
}
