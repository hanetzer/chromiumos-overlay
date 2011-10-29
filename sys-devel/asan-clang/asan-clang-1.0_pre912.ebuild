# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/clang/clang-9999.ebuild,v 1.15 2011/07/08 10:10:59 ssuominen Exp $
#
# This package installs LLVM's Clang of the revision we use for
# Address Sanitizer. The Clang may be used alone and the revision is
# usually recent enough for ChromeOS modules.
#
# This package is originated from
# http://sources.gentoo.org/sys-devel/clang/clang-9999.ebuild
#
# Note that we use downloading sources from SVN because llvn.org has
# not released this version yet.

EAPI=3

inherit subversion eutils multilib

DESCRIPTION="Address Sanitizer based on Clang"
HOMEPAGE="http://address-sanitizer.googlecode.com/"
SRC_URI=""
ESVN_REPO_URI="http://address-sanitizer.googlecode.com/svn/trunk"@${PV#*_pre}

LICENSE="UoI-NCSA"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="+alltargets +asan +cxx-sysroot-wrapper debug -system-cxx-headers test"

S="${WORKDIR}/asan"

src_unpack() {
	ESVN_PROJECT=asan subversion_fetch
	local LLVM_REV=$(. "${S}/llvm/config.sh"; echo ${LLVM_REV})
	elog "Clang revision to get is ${LLVM_REV}."

	# Fetching LLVM as well: see http://llvm.org/bugs/show_bug.cgi?id=4840
	ESVN_PROJECT=llvm S="${S}"/clang_src \
		subversion_fetch "http://llvm.org/svn/llvm-project/llvm/trunk"@${LLVM_REV}
	ESVN_PROJECT=clang S="${S}"/clang_src/tools/clang \
		subversion_fetch "http://llvm.org/svn/llvm-project/cfe/trunk"@${LLVM_REV}
}

src_prepare() {
	if use asan; then
	       "${S}/llvm/patch_clang.sh"
	fi
}

src_configure() {
	local CONF_FLAGS=""

	if use debug; then
		CONF_FLAGS="${CONF_FLAGS} --disable-optimized"
		einfo "Note: Compiling LLVM in debug mode will create huge and slow binaries"
		# ...and you probably shouldn't use tmpfs, unless it can hold 900MB
	else
		CONF_FLAGS="${CONF_FLAGS} \
			--enable-optimized \
			--disable-assertions \
			--disable-expensive-checks"
	fi

	# Setup the search path to include the Prefix includes
	if use prefix ; then
		CONF_FLAGS="${CONF_FLAGS} \
			--with-c-include-dirs=${EPREFIX}/usr/include:/usr/include"
	fi

	if use alltargets; then
		CONF_FLAGS="${CONF_FLAGS} --enable-targets=all"
	else
		CONF_FLAGS="${CONF_FLAGS} --enable-targets=host-only"
	fi

	if use amd64; then
		CONF_FLAGS="${CONF_FLAGS} --enable-pic"
	fi

	# Skip llvm-gcc parts even if installed
	CONF_FLAGS="${CONF_FLAGS} --with-llvmgccdir=/dev/null"

	if use system-cxx-headers; then
		# Try to get current gcc headers path
		local CXX_PATH=$(gcc-config -X| cut -d: -f1 | sed 's,/include/g++-v4$,,')
		CONF_FLAGS="${CONF_FLAGS} --with-c-include-dirs=/usr/include:${CXX_PATH}/include"
		CONF_FLAGS="${CONF_FLAGS} --with-cxx-include-root=${CXX_PATH}/include/g++-v4"
		CONF_FLAGS="${CONF_FLAGS} --with-cxx-include-arch=$CHOST"
		if has_multilib_profile; then
			CONF_FLAGS="${CONF_FLAGS} --with-cxx-include-32bit-dir=32"
		fi
	fi

	cd "${S}"/clang_src || die "cd failed"
	econf ${CONF_FLAGS} || die "econf failed"
}

src_compile() {
	cd "${S}"/clang_src || die "cd failed"
	emake VERBOSE=1 KEEP_SYMBOLS=1 REQUIRES_RTTI=1 clang-only || die "emake failed"
	if use asan; then
		cd "${S}"/asan || die "cd to ASAN failed"
		emake ASAN_FLAGS=-march=i686 CLANG_BUILD="${S}"/asan lib32 ||
			die "emake ASAN library 32 failed"
		emake CLANG_BUILD="${S}"/asan lib64 ||
			die "emake ASAN library 64 failed"
	fi
}

src_test() {
	cd "${S}"/clang_src/test || die "cd failed"
	emake site.exp || die "updating llvm site.exp failed"

	cd "${S}"/clang_src/tools/clang || die "cd clang failed"

	echo ">>> Test phase [test]: ${CATEGORY}/${PF}"
	if ! emake -j1 VERBOSE=1 test; then
		has test $FEATURES && die "Make test failed. See above for details."
		has test $FEATURES || eerror "Make test failed. See above for details."
	fi

	if use asan; then
		cd "${S}"/asan || die "cd to ASAN failed"
		emake CLANG_BUILD="${S}"/asan CLANG_CXX=clang++ t32 t64 ||
			die "emake ASAN tests failed"
	fi
}

src_install() {
	cd "${S}"/clang_src/tools/clang || die "cd clang failed"
	emake KEEP_SYMBOLS=1 DESTDIR="${D}" install || die "install failed"

	if use cxx-sysroot-wrapper; then
		# Try to get current gcc headers path
		local CXX_PATH=$(gcc-config -X| cut -d: -f1 | sed 's,/include/g++-v4$,,')

		# Create the wrapper script that will substitute right libstlc++ paths.
		# This is needed because Clang --sysroot=<sysroot>, unlike gcc, prepends
		# its cxx-include-root with <sysroot> making it unusable.
		# Clang maintainers consider this the right behavior (crbug.com/86037)
		# although the Clang own includes (/usr/lib/clang/3.x/include) are never
		# prepended with <sysroot>.
		cat <<-EOF >"${S}/clang++.sh" || die
			#!/bin/sh
			exec clang++.real "\$@" \
				-I${CXX_PATH}/include-fixed \
				-I${CXX_PATH}/include/g++-v4 \
				-I${CXX_PATH}/include/g++-v4/x86_64-pc-linux-gnu \
				-I${CXX_PATH}/include/g++-v4/backward
		EOF
		dobin "${S}/clang++.sh" || die

		# Make Clang take cxxabi.h from the right place. Needed by gTest.
		# Unfortunately adding -I${CXX_PATH}/include, where right cxxabi.h resides,
		# breaks the compilation. This is because Clang prefers this directory to
		# its own (/usr/lib/clang/3.x/include) despite declaration order,
		# thus it takes some includes (xmmintrin.h) from there and it drives Clang mad.
		dosym ${CXX_PATH}/include/cxxabi.h "${EPREFIX}/usr/$(get_libdir)/clang/3.0/include/"
	fi

	if use asan; then
		cd "${S}"/asan || die "cd to ASAN failed"
		dodir /usr/lib
		emake CLANG_BUILD="${S}"/asan INSTALL_DIR="${ED}"/usr install_lib ||
			die "emake install of ASAN library failed"
	fi
}

pkg_postinst() {
	mv "${EPREFIX}/usr/bin/clang++" "${EPREFIX}/usr/bin/clang++.real"
	mv "${EPREFIX}/usr/bin/clang++.sh" "${EPREFIX}/usr/bin/clang++"

	if use system-cxx-headers; then
		elog "C++ headers search path is hardcoded to the active gcc profile one"
		elog "If you change the active gcc profile, or update gcc to a new version,"
		elog "you will have to remerge this package to update the search path"
	else
		elog "If clang++ fails to find C++ headers on your system,"
		elog "you can remerge clang with USE=system-cxx-headers to use C++ headers"
		elog "from the active gcc profile"
	fi
}
