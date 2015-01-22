# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/protobuf/protobuf-2.3.0-r1.ebuild,v 1.5 2011/03/16 18:00:10 xarthisius Exp $

EAPI="4"

JAVA_PKG_IUSE="source"
PYTHON_COMPAT=( python2_7 )
DISTUTILS_OPTIONAL=1

inherit autotools eutils distutils-r1 java-pkg-opt-2 elisp-common toolchain-funcs

DESCRIPTION="Google's Protocol Buffers -- an efficient method of encoding structured data"
HOMEPAGE="http://code.google.com/p/protobuf/"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${P}.tar.bz2"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="emacs examples java python static-libs vim-syntax"

CDEPEND="emacs? ( virtual/emacs )
	python? ( ${PYTHON_DEPS} )"
DEPEND="${CDEPEND}
	java? ( >=virtual/jdk-1.5 )
	python? ( dev-python/setuptools[${PYTHON_USEDEP}] )
	emacs? ( virtual/emacs )"
RDEPEND="${CDEPEND}
	java? ( >=virtual/jre-1.5 )"

src_prepare() {
	epatch "${FILESDIR}"/${P}-asneeded-2.patch
	epatch "${FILESDIR}"/${P}-crosscompile.patch
	epatch "${FILESDIR}"/${P}-protoc_redirect_io.patch
	eautoreconf

	if use python; then
		cd python && distutils-r1_src_prepare
	fi
}

src_configure() {
	PROTOC_ARG=
	if tc-is-cross-compiler ; then
		host_protoc=$(which protoc)
		[[ -n ${host_protoc} ]] || die "Please install ${P} in your host environment."
		PROTOC_ARG="--with-protoc=${host_protoc}"
		export PROTOC=${host_protoc}
	fi

	export LDFLAGS="-L./.libs ${LDFLAGS}"
	econf $PROTOC_ARG \
		$(use_enable static-libs static)
}

src_compile() {
	emake || die "emake failed"

	if use python; then
		einfo "Compiling Python library ..."
		pushd "${S}"/python >/dev/null
		PROTOC="${BUILD_DIR}"/src/protoc distutils-r1_src_compile
		popd >/dev/null
	fi

	if use java; then
		einfo "Compiling Java library ..."
		src/protoc --java_out=java/src/main/java --proto_path=src src/google/protobuf/descriptor.proto
		mkdir java/build
		pushd java/src/main/java
		ejavac -d ../../../build $(find . -name '*.java') || die "java compilation failed"
		popd
		jar cf "${PN}.jar" -C java/build . || die "jar failed"
	fi

	if use emacs; then
		elisp-compile "${S}/editors/protobuf-mode.el" || die "elisp-compile failed!"
	fi
}

src_test() {
	emake check || die "emake check failed"

	if use python; then
		 pushd python >/dev/null
		 distutils-r1_src_test
		 popd >/dev/null
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc CHANGES.txt CONTRIBUTORS.txt README.txt

	use static-libs || rm -rf "${D}"/usr/lib*/*.la

	if use python; then
		pushd python >/dev/null
		distutils-r1_python_install --prefix=/usr/local
		popd >/dev/null
		# HACK ALERT: upstream setup.py forgets to install google/__init__.py,
		# hack now, fix properly later.
		pushd "${D}" >/dev/null
		local whereto="$(find . -name 'site-packages')"
		popd >/dev/null
		insinto "${whereto/./}"/google/
		doins "${S}"/python/google/__init__.py
	fi

	if use java; then
		java-pkg_dojar ${PN}.jar
		use source && java-pkg_dosrc java/src/main/java/*
	fi

	if use vim-syntax; then
		insinto /usr/share/vim/vimfiles/syntax
		doins editors/proto.vim
	fi

	if use emacs; then
		elisp-install ${PN} editors/protobuf-mode.el* || die "elisp-install failed!"
		elisp-site-file-install "${FILESDIR}/70${PN}-gentoo.el"
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r examples/* || die "doins examples failed"
	fi
}

pkg_postinst() {
	use emacs && elisp-site-regen
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
