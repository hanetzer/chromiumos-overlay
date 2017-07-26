# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_PROJECT="chromiumos/third_party/coreboot"
CROS_WORKON_SUBDIRS_TO_COPY="util/crossgcc"
CROS_WORKON_SUBDIRS_TO_REV="util/crossgcc"
CROS_WORKON_LOCALNAME="coreboot"

inherit cros-workon toolchain-funcs multiprocessing

DESCRIPTION="upstream coreboot's compiler suite"
HOMEPAGE="https://www.coreboot.org"
LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="~*"

# URIs taken from buildgcc -u
# Needs to be synced with changes in the coreboot repo,
# then pruned to the minimum required set (eg. no gdb, python, expat, llvm)
CROSSGCC_URIS="
http://ftpmirror.gnu.org/gmp/gmp-6.1.2.tar.xz
http://ftpmirror.gnu.org/mpfr/mpfr-3.1.5.tar.xz
http://ftpmirror.gnu.org/mpc/mpc-1.0.3.tar.gz
http://www.mr511.de/software/libelf-0.8.13.tar.gz
http://ftpmirror.gnu.org/gcc/gcc-6.3.0/gcc-6.3.0.tar.bz2
http://ftpmirror.gnu.org/binutils/binutils-2.28.tar.bz2
https://acpica.org/sites/acpica/files/acpica-unix2-20161222.tar.gz
http://ftpmirror.gnu.org/make/make-4.2.1.tar.bz2
"

SRC_URI="
${CROSSGCC_URIS}
http://mirrors.cdn.adacore.com/art/591c6d80c7a447af2deed1d7 -> gnat-gpl-2017-x86_64-linux-bin.tar.gz
"

src_prepare() {
	mkdir util/crossgcc/tarballs
	ln -s "${DISTDIR}"/* util/crossgcc/tarballs/
	unpack gnat-gpl-2017-x86_64-linux-bin.tar.gz
	# buildgcc uses 'cc' to find gnat1 so it needs to find the gnat-gpl
	# compiler under that name
	ln -s gcc gnat-gpl-2017-x86_64-linux-bin/bin/cc
}

src_compile() {
	# To bootstrap the Ada build, an Ada compiler needs to be available. To
	# make sure it interacts well with the C/C++ parts of the compiler,
	# buildgcc asks gcc for the Ada compiler's path using the compiler's
	# -print-prog-name option which only deals with programs from the very
	# same compiler distribution, so make sure we use the right one.
	export PATH="${S}"/gnat-gpl-2017-x86_64-linux-bin/bin:"${PATH}"
	export CC=gcc CXX=g++

	# make calls into buildgcc, which then uses CPUS to parallelize its
	# make(1) children. Therefore only -j1 on the top-level.
	emake -j1 all_without_gdb \
		-C util/crossgcc \
		SKIP_CLANG=1 \
		CPUS=$(makeopts_jobs) \
		BUILD_LANGUAGES=c,ada \
		KEEP_SOURCES=1 \
		DEST=/opt/coreboot-sdk \
		BUILDGCC_OPTIONS='-D "${S}"/out -b' \
		|| die "building the toolchain failed"
}

src_install() {
	dodir out/opt
	cp -a out/opt/coreboot-sdk "${D}"/opt/coreboot-sdk || die
}
