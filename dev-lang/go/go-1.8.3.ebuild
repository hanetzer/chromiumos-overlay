# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

inherit eutils toolchain-funcs

# Version used to bootstrap the build.
BOOTSTRAP="go1.4-bootstrap-20161024"

DESCRIPTION="An expressive, concurrent, garbage-collected programming language"
HOMEPAGE="http://golang.org/"
SRC_URI="https://storage.googleapis.com/golang/go${PV}.src.tar.gz
	https://storage.googleapis.com/golang/${BOOTSTRAP}.tar.gz"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="-* amd64 arm arm64 x86"
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
		arm64) echo "arm64" ;;
	esac
}

src_unpack() {
	unpack "go${PV}.src.tar.gz"
	mv go "go-${PV}"
	unpack "${BOOTSTRAP}.tar.gz"
	mv go "${BOOTSTRAP}"
}

src_configure() {
	export GOROOT_BOOTSTRAP="${WORKDIR}/${BOOTSTRAP}"
	export GOROOT_FINAL="${EPREFIX}$(get_goroot)"
}

src_compile() {
	einfo "Building the bootstrap compiler."
	cd "${GOROOT_BOOTSTRAP}/src"
	# Build the bootstrap compiler with Cgo disabled.
	#  - https://bugs.chromium.org/p/chromium/issues/detail?id=712784
	CGO_ENABLED="0" ./make.bash || die

	cd "${S}/src"
	einfo "Building the cross compiler for ${CTARGET}."
	GOOS="linux" GOARCH="$(get_goarch ${CTARGET})" CGO_ENABLED="1" \
		CC_FOR_TARGET="$(tc-getTARGET_CC)" \
		CXX_FOR_TARGET="$(tc-getTARGET_CXX)" \
		./make.bash || die

	if is_cross ; then
		einfo "Building the standard library with -buildmode=pie."
		GOOS="linux" GOARCH="$(get_goarch ${CTARGET})" CGO_ENABLED="1" \
			CC="$(tc-getTARGET_CC)" \
			CXX="$(tc-getTARGET_CXX)" \
			GOROOT="${S}" \
			"${S}/bin/go" install -v -buildmode=pie std || die
	fi
}

src_install() {
	local goroot="$(get_goroot)"
	local tooldir="pkg/tool/linux_$(get_goarch ${CBUILD})"

	insinto "${goroot}"
	doins -r src lib

	exeinto "${goroot}/bin"
	doexe bin/{go,gofmt}

	insinto "${goroot}/pkg"
	doins -r "pkg/include"
	doins -r "pkg/linux_$(get_goarch ${CTARGET})"
	if is_cross ; then
		doins -r "pkg/linux_$(get_goarch ${CTARGET})_shared"
	fi

	exeinto "${goroot}/${tooldir}"
	doexe "${tooldir}/"{asm,cgo,compile,link,pack}
	doexe "${tooldir}/"{doc,fix,vet}
	doexe "${tooldir}/"{cover,pprof,trace}
	doexe "${tooldir}/"{addr2line,nm,objdump}

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
	else
		dosym "${goroot}/bin/go" /usr/bin/go
		dosym "${goroot}/bin/gofmt" /usr/bin/gofmt
		# Setup the wrapper for invoking the host compiler.
		# See "files/host_wrapper.py" for details.
		newbin "${FILESDIR}/host_wrapper.py" "${CTARGET}-go"
	fi

	# Fill in variable values in the compiler wrapper.
	sed -e "s:@GOARCH@:$(get_goarch ${CTARGET}):" \
		-e "s:@CC@:$(tc-getTARGET_CC):" \
		-e "s:@CXX@:$(tc-getTARGET_CXX):" \
		-e "s:@GOTOOL@:${GOROOT_FINAL}/bin/go:" \
		-i "${D}/usr/bin/${CTARGET}-go" || die
}
