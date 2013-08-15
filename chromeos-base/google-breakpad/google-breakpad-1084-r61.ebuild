# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="f1f5090c82314f281c6934d10494f1d0a66bc8a7"
CROS_WORKON_TREE="1063e2d5af03d48f83cf6accaf04027fd6611dea"
CROS_WORKON_PROJECT="chromiumos/platform/google-breakpad"

inherit autotools cros-debug cros-workon toolchain-funcs flag-o-matic multiprocessing

DESCRIPTION="Google crash reporting"
HOMEPAGE="http://code.google.com/p/google-breakpad"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE="cros_host"

RDEPEND="net-misc/curl"
DEPEND="${RDEPEND}"

src_prepare() {
	[[ ${ABI} == "x32" ]] && epatch "${FILESDIR}"/lss-x32.patch

	eautoreconf
}

src_configure() {
	#TODO(raymes): Uprev breakpad so this isn't necessary. See
	# (crosbug.com/14275).
	[[ "${ARCH}" = "arm" ]] && append-flags "-marm"

	# We purposefully disable optimizations due to optimizations causing
	# src/processor code to crash (minidump_stackwalk) as well as tests
	# to fail.  See
	# http://code.google.com/p/google-breakpad/issues/detail?id=400.
	append-flags "-O0" -g

	tc-export CC CXX LD PKG_CONFIG

	multijob_init

	mkdir build
	pushd build >/dev/null
	ECONF_SOURCE=${S} multijob_child_init cros-workon_src_configure
	popd >/dev/null

	if use cros_host; then
		einfo "Building a 32-bit version of tools"
		mkdir work32
		pushd work32 >/dev/null
		append-flags "-m32"
		append-lfs-flags # crbug.com/266064
		ECONF_SOURCE=${S} multijob_child_init cros-workon_src_configure
		filter-lfs-flags
		filter-flags "-m32"
		popd >/dev/null
	fi

	multijob_finish
}

src_compile() {
	emake -C build

	if use cros_host; then
		einfo "Building 32-bit tools"
		emake -C work32 \
			src/tools/linux/dump_syms/dump_syms \
			src/tools/linux/md2core/minidump-2-core
	fi
}

src_test() {
	emake -C build check
}

src_install() {
	pushd build >/dev/null
	emake DESTDIR="${D}" install
	dobin src/tools/linux/core2md/core2md \
	      src/tools/linux/md2core/minidump-2-core \
	      src/tools/linux/dump_syms/dump_syms \
	      src/tools/linux/symupload/sym_upload \
	      src/tools/linux/symupload/minidump_upload
	popd >/dev/null

	insinto /usr/include/google-breakpad/client/linux/handler
	doins src/client/linux/handler/*.h
	insinto /usr/include/google-breakpad/client/linux/crash_generation
	doins src/client/linux/crash_generation/*.h
	insinto /usr/include/google-breakpad/common/linux
	doins src/common/linux/*.h
	insinto /usr/include/google-breakpad/processor
	doins src/processor/*.h

	if use cros_host; then
		newbin work32/src/tools/linux/dump_syms/dump_syms dump_syms.32
		newbin work32/src/tools/linux/md2core/minidump-2-core \
		       minidump-2-core.32
	fi
}
