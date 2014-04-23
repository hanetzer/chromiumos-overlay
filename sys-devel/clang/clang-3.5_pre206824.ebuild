# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
#
# This package is originated from
# http://sources.gentoo.org/sys-devel/clang/clang-9999.ebuild
#
# Note that we use downloading sources from SVN because llvm.org has
# not released this version yet.

EAPI=5

PYTHON_COMPAT=( python{2_6,2_7} pypy2_0 )

inherit cros-constants subversion eutils multilib python-r1

EGIT_REPO_URIS=(
	"llvm"
		""
		#"git://github.com/llvm-mirror/llvm.git"
		#"http://llvm.org/git/llvm.git"
		"${CROS_GIT_HOST_URL}/chromiumos/third_party/llvm.git"
		"262f39ed3a8969f07ca7cb4a53bf34d46c1d4351" # EGIT_COMMIT
	"compiler-rt"
		"projects/compiler-rt"
		#"git://github.com/llvm-mirror/compiler-rt.git"
		#"http://llvm.org/git/compiler-rt.git"
		"${CROS_GIT_HOST_URL}/chromiumos/third_party/compiler-rt.git"
		"a915ac3430a267bb2984787acc5b096c6c3be879" # EGIT_COMMIT
	"clang"
		"tools/clang"
		#"git://github.com/llvm-mirror/clang.git"
		#"http://llvm.org/git/clang.git"
		"${CROS_GIT_HOST_URL}/chromiumos/third_party/clang.git"
		"e2f48e941c2faecd1154ee8dec9458377b99aa4f"  # EGIT_COMMIT
)
inherit git-2

SVN_COMMIT=${PV#*_pre}

DESCRIPTION="C language family frontend for LLVM"
HOMEPAGE="http://clang.llvm.org/"
SRC_URI=""
ESVN_REPO_URI="http://llvm.org/svn/llvm-project/cfe/trunk@${SVN_COMMIT}"

LICENSE="UoI-NCSA"
SLOT="0"
KEYWORDS="-* amd64"
IUSE="debug multitarget python +static-analyzer test"

DEPEND="static-analyzer? ( dev-lang/perl )"
RDEPEND="~sys-devel/llvm-${PV}[multitarget=]"

S="${WORKDIR}/llvm"

src_unpack() {
	set -- "${EGIT_REPO_URIS[@]}"
	while [[ $# -gt 0 ]]; do
		ESVN_PROJECT=$1 \
		EGIT_SOURCEDIR="${S}/$2" \
		EGIT_REPO_URI=$3 \
		EGIT_COMMIT=$4 \
		git-2_src_unpack
		shift 4
	done
	return

	# Fetching LLVM and subprojects
	ESVN_PROJECT=llvm subversion_fetch "http://llvm.org/svn/llvm-project/llvm/trunk@${SVN_COMMIT}"
	ESVN_PROJECT=compiler-rt S="${S}"/projects/compiler-rt subversion_fetch "http://llvm.org/svn/llvm-project/compiler-rt/trunk@${SVN_COMMIT}"
	ESVN_PROJECT=clang S="${S}"/tools/clang subversion_fetch
}

src_prepare() {
	if [ "/usr/x86_64-pc-linux-gnu/gcc-bin/4.8.x-google" != $(gcc-config -B) ]; then
		ewarn "Beware sheriff: gcc's binaries are not in '/usr/x86_64-pc-linux-gnu/gcc-bin/4.8.x-google'"
		ewarn "and are instead in $(gcc-config -B). This may lead to an unusable clang."
		ewarn "Please test clang with a simple hello_world.cc file and update this message."
	fi

	# Change the default asan output path
	epatch "${FILESDIR}"/${PN}-3.5-asan-default-path.patch

	# Same as llvm doc patches
	epatch "${FILESDIR}"/${PN}-2.7-fixdoc.patch

	# multilib-strict
	sed -e "/PROJ_resources\|ResourceDir/s#lib/clang#$(get_libdir)/clang#" \
		-i tools/clang/runtime/compiler-rt/Makefile \
		|| die "compiler-rt Makefile sed failed"
	sed -e "s#/lib/#/lib{{(32|64)?}}/#" \
		-i tools/clang/test/Preprocessor/iwithprefix.c \
		|| die "clang test sed failed"

	# From llvm src_prepare
	einfo "Fixing install dirs"
	sed -e 's,^PROJ_docsdir.*,PROJ_docsdir := $(PROJ_prefix)/share/doc/'${PF}, \
		-e 's,^PROJ_etcdir.*,PROJ_etcdir := '"${EPREFIX}"'/etc/llvm,' \
		-e 's,^PROJ_libdir.*,PROJ_libdir := $(PROJ_prefix)/'$(get_libdir)/llvm, \
		-i Makefile.config.in || die "Makefile.config sed failed"

	einfo "Fixing rpath and CFLAGS"
	sed -e 's,\$(RPATH) -Wl\,\$(\(ToolDir\|LibDir\)),$(RPATH) -Wl\,'"${EPREFIX}"/usr/$(get_libdir)/llvm, \
		-e '/OmitFramePointer/s/-fomit-frame-pointer//' \
		-e 's%\x27$$ORIGIN/../lib\x27%& $(RPATH) -Wl,\x27$(PROJ_libdir)\x27%g' \
		-i Makefile.rules || die "rpath sed failed"

	# Use system llc (from llvm ebuild) for tests
	sed -e "/^llc_props =/s/os.path.join(llvm_tools_dir, 'llc')/'llc'/" \
		-i tools/clang/test/lit.cfg  || die "test path sed failed"

	# User patches
	epatch_user
}

src_configure() {
	# Update resource dir version after first RC
	local CONF_FLAGS="--enable-shared
		--with-optimize-option=
		$(use_enable !debug optimized)
		$(use_enable debug assertions)
		$(use_enable debug expensive-checks)"

	# Setup the search path to include the Prefix includes
	if use prefix ; then
		CONF_FLAGS="${CONF_FLAGS} \
			--with-c-include-dirs=${EPREFIX}/usr/include:/usr/include"
	fi

	if use multitarget; then
		CONF_FLAGS="${CONF_FLAGS} --enable-targets=all"
	else
		CONF_FLAGS="${CONF_FLAGS} --enable-targets=host,cpp"
	fi

	if use amd64; then
		CONF_FLAGS="${CONF_FLAGS} --enable-pic"
	fi

	# build with a suitable Python version
	python_export_best

	# clang prefers clang over gcc, so we may need to force that
	tc-export CC CXX

	econf ${CONF_FLAGS}
}

src_compile() {
	emake VERBOSE=1 KEEP_SYMBOLS=1 REQUIRES_RTTI=1 clang-only
}

src_test() {
	cd "${S}"/tools/clang || die "cd clang failed"

	echo ">>> Test phase [test]: ${CATEGORY}/${PF}"

	if ! emake -j1 VERBOSE=1 test; then
		has test $FEATURES && die "Make test failed. See above for details."
		has test $FEATURES || eerror "Make test failed. See above for details."
	fi
}

src_install() {
	cd "${S}"/tools/clang || die "cd clang failed"
	emake KEEP_SYMBOLS=1 DESTDIR="${D}" install

	if use static-analyzer ; then
		dobin tools/scan-build/ccc-analyzer
		dosym ccc-analyzer /usr/bin/c++-analyzer
		dobin tools/scan-build/scan-build

		insinto /usr/share/${PN}
		doins tools/scan-build/scanview.css
		doins tools/scan-build/sorttable.js
	fi

	python_inst() {
		if use static-analyzer ; then
			pushd tools/scan-view >/dev/null || die

			python_doscript scan-view

			touch __init__.py || die
			python_moduleinto clang
			python_domodule __init__.py Reporter.py Resources ScanView.py startfile.py

			popd >/dev/null || die
		fi

		if use python ; then
			pushd bindings/python/clang >/dev/null || die

			python_moduleinto clang
			python_domodule __init__.py cindex.py enumerations.py

			popd >/dev/null || die
		fi

		# AddressSanitizer symbolizer (currently separate)
		python_doscript "${S}"/projects/compiler-rt/lib/asan/scripts/asan_symbolize.py
	}
	python_foreach_impl python_inst

	# Fix install_names on Darwin.  The build system is too complicated
	# to just fix this, so we correct it post-install
	if [[ ${CHOST} == *-darwin* ]] ; then
		for lib in libclang.dylib ; do
			ebegin "fixing install_name of $lib"
			install_name_tool -id "${EPREFIX}"/usr/lib/llvm/${lib} \
				"${ED}"/usr/lib/llvm/${lib}
			eend $?
		done
		for f in usr/bin/{c-index-test,clang} usr/lib/llvm/libclang.dylib ; do
			ebegin "fixing references in ${f##*/}"
			install_name_tool \
				-change "@rpath/libclang.dylib" \
					"${EPREFIX}"/usr/lib/llvm/libclang.dylib \
				-change "@executable_path/../lib/libLLVM-${PV}.dylib" \
					"${EPREFIX}"/usr/lib/llvm/libLLVM-${PV}.dylib \
				-change "${S}"/Release/lib/libclang.dylib \
					"${EPREFIX}"/usr/lib/llvm/libclang.dylib \
				"${ED}"/$f
			eend $?
		done
	fi
}
