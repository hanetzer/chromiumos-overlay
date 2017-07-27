# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

#
# Original Author: The Chromium OS Authors <chromium-os-dev@chromium.org>
# Purpose: Library for supporting the Go programming language in Chromium OS.
#

# @ECLASS-VARIABLE: CROS_GO_WORKSPACE
# @DESCRIPTION:
# Path to the Go workspace, default is ${S}

# @ECLASS-VARIABLE: CROS_GO_BINARIES
# @DESCRIPTION:
# Go executable binaries to build and install
# Package paths are relative to ${CROS_GO_WORKSPACE}/src
# Each path must contain a package "main". The last component
# of the package path will become the name of the executable.
# The executable name can be overridden by appending a colon
# to the package path, followed by an alternate name.
# For example:
#   CROS_GO_BINARIES=(
#     "golang.org/x/tools/cmd/godoc"
#     "golang.org/x/tools/cmd/guru:goguru"
#   )
# will build and install "godoc" and "goguru" binaries.

# @ECLASS-VARIABLE: CROS_GO_PACKAGES
# @DESCRIPTION:
# Go packages to install in /usr/lib/gopath
# Package paths are relative to ${CROS_GO_WORKSPACE}/src
# Packages are installed in /usr/lib/gopath such that they
# can be imported later from Go code using the exact paths
# listed here. For example:
#   CROS_GO_PACKAGES=(
#     "github.com/golang/glog"
#   )
# will install package files
#   from "${CROS_GO_WORKSPACE}/src/github.com/golang/glog"
#   to "/usr/lib/gopath/src/github.com/golang/glog"
# and other Go projects can use the package with
#   import "github.com/golang/glog"

# @ECLASS-VARIABLE: CROS_GO_TEST
# @DESCRIPTION:
# Go packages to test
# Package paths are relative to ${CROS_GO_WORKSPACE}/src
# Package tests are always built and run locally on host.
# Default is to test all packages in ${CROS_GO_WORKSPACE}.
: ${CROS_GO_TEST:=./...}

inherit toolchain-funcs

DEPEND="dev-lang/go"

cros_go() {
	local workspace="${CROS_GO_WORKSPACE:-${S}}"
	GOPATH="${workspace}:${SYSROOT}/usr/lib/gopath" \
		$(tc-getGO) "$@" || die
}

go_test() {
	local workspace="${CROS_GO_WORKSPACE:-${S}}"
	GOPATH="${workspace}:${SYSROOT}/usr/lib/gopath" \
		$(tc-getBUILD_GO) test "$@" || die
}

cros-go_src_compile() {
	local bin
	for bin in "${CROS_GO_BINARIES[@]}" ; do
		local name="${bin##*/}"
		name="${name#*:}"
		bin="${bin%:*}"
		cros_go build -v -o "${name}" "${bin}"
	done
}

cros-go_src_test() {
	go_test "${CROS_GO_TEST[@]}"
}

cros-go_src_install() {
	local workspace="${CROS_GO_WORKSPACE:-${S}}"

	# Install the compiled binaries.
	local bin
	for bin in "${CROS_GO_BINARIES[@]}" ; do
		local name="${bin##*/}"
		name="${name#*:}"
		dobin "${name}"
	done

	# Install the importable packages in /usr/lib/gopath.
	local pkg
	for pkg in "${CROS_GO_PACKAGES[@]}" ; do
		local pkgdir="${workspace}/src/${pkg}"
		[[ -d "${pkgdir}" ]] || die "Package not found: \"${pkg}\""
		(
			# Run in sub-shell so we do not modify env.
			insinto "/usr/lib/gopath/src/${pkg}"
			local file
			while read -d $'\0' -r file ; do
				doins "${file}"
			done < <(find "${pkgdir}" -maxdepth 1 ! -type d -print0)
		)
	done

	# Check for missing dependencies of installed packages.
	local CROS_GO_WORKSPACE="${D}/usr/lib/gopath"
	for pkg in "${CROS_GO_PACKAGES[@]}" ; do
		if [[ $(cros_go list -f "{{.Incomplete}}" "${pkg}") == "true" ]] ; then
			cros_go list -f "{{.DepsErrors}}" "${pkg}"
			die "Package has missing dependency: \"${pkg}\""
		fi
	done
}

EXPORT_FUNCTIONS src_compile src_test src_install
