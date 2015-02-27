# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

inherit eutils toolchain-funcs

DESCRIPTION="An expressive, concurrent, garbage-collected programming language"
HOMEPAGE="http://golang.org/"
SRC_URI="https://storage.googleapis.com/golang/go${PV}.src.tar.gz"
S="${WORKDIR}/${PN}"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="-* amd64"
IUSE=""
RESTRICT="binchecks strip"

is_cross() {
	[[ "${CATEGORY}" == cross-* ]]
}

DEPEND=""
if is_cross ; then
	DEPEND="${CATEGORY}/gcc"
fi
RDEPEND="${DEPEND}"

export CTARGET="${CTARGET:-${CHOST}}"
if [[ "${CTARGET}" == "${CHOST}" ]] ; then
	if is_cross ; then
		CTARGET="${CATEGORY#cross-}"
	fi
fi

get_goroot() {
	if is_cross ; then
		echo "/usr/lib/go/${CTARGET}"
	else
		echo "/usr/lib/go"
	fi
}

get_goarch() {
	case "$(tc-arch $1)" in
		amd64) echo "amd64" ;;
		x86) echo "386" ;;
		arm) echo "arm" ;;
	esac
}

get_gochar() {
	case "$(get_goarch $1)" in
		amd64) echo "6" ;;
		386) echo "8" ;;
		arm) echo "5" ;;
	esac
}

src_prepare() {
	epatch "${FILESDIR}/${P}-no-strict-overflow.patch"
}

src_configure() {
	export GOROOT_FINAL="${EPREFIX}$(get_goroot)"
}

src_compile() {
	cd src
	GOOS="linux" GOARCH="$(get_goarch ${CTARGET})" CGO_ENABLED="1" \
		CC_FOR_TARGET="$(tc-getCC ${CTARGET})" \
		CXX_FOR_TARGET="$(tc-getCXX ${CTARGET})" \
		./make.bash || die
}

src_install() {
	local goroot="$(get_goroot)"
	local tooldir="pkg/tool/linux_$(get_goarch ${CBUILD})"

	insinto "${goroot}"
	doins -r src lib

	exeinto "${goroot}/bin"
	doexe bin/{go,gofmt}

	insinto "${goroot}/pkg"
	doins -r "pkg/linux_$(get_goarch ${CTARGET})"

	exeinto "${goroot}/${tooldir}"
	doexe "${tooldir}/$(get_gochar ${CTARGET})"{a,c,g,l}
	doexe "${tooldir}/"{addr2line,cgo,fix,nm,objdump,pack,pprof,yacc}

	# Fix timestamps of precompiled standard library packages.
	#
	# The Go tool uses timestamps to determine which packages are stale. This
	# is also true for precompiled standard library packages. When compiling
	# user programs, the Go tool ends up recompiling most of the standard
	# library on every invocation, instead of using the installed version.
	#
	# As an example, package 'regexp' imports package 'bytes'. If 'bytes.a' has
	# a timestamp newer than 'regexp.a', package 'regexp' is considered out of
	# date. When a user program imports 'regexp', the Go tool will end up
	# recompiling package 'regexp' in a temporary directory instead of using
	# the precompiled 'regexp.a' from the installation.
	#
	# We fix this by making the timestamp of every installed standard library
	# package identical, using the timestamp of the Go tool itself as reference.
	#
	# After this is done, the following command should not print any output:
	#   go list -f "{{if .Stale}}{{.ImportPath}}{{end}}" std
	find "${D}/${goroot}/pkg" -type f \
		-exec touch -r "${D}/${goroot}/bin/go" {} + || die

	if is_cross ; then
		# Setup the wrapper for invoking the cross compiler.
		# See "files/pie_wrapper.py" for details.
		newbin "${FILESDIR}/pie_wrapper.py" "${CTARGET}-go"
		sed -e "s:@GOARCH@:$(get_goarch ${CTARGET}):" \
			-e "s:@CC@:$(tc-getCC ${CTARGET}):" \
			-e "s:@CXX@:$(tc-getCXX ${CTARGET}):" \
			-e "s:@GOTOOL@:${GOROOT_FINAL}/bin/go:" \
			-i "${D}/usr/bin/${CTARGET}-go" || die
	else
		dosym "${goroot}/bin/go" /usr/bin/go
		dosym "${goroot}/bin/gofmt" /usr/bin/gofmt
	fi
}
