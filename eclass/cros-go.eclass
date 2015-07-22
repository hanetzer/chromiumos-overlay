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
#     "golang.org/x/tools/cmd/vet:govet"
#   )
# will build and install "godoc" and "govet" binaries.

# @ECLASS-VARIABLE: CROS_GO_PACKAGES
# @DESCRIPTION:
# Go packages to install in /usr/lib/gopath
# Package paths are relative to ${CROS_GO_WORKSPACE}/src
# Packages are installed in /usr/lib/gopath such that they
# can be imported later from Go code using the exact paths
# listed here. For example:
#   CROS_GO_PACKAGES=(
#     "golang.org/x/tools/go/types"
#   )
# will install package files
#   from "${CROS_GO_WORKSPACE}/src/golang.org/x/tools/go/types"
#   to "/usr/lib/gopath/src/golang.org/x/tools/go/types"
# and other Go projects can use the package with
#   import "golang.org/x/tools/go/types"

inherit toolchain-funcs

cros_go() {
	local workspace="${CROS_GO_WORKSPACE:-${S}}"
	GOPATH="${workspace}:${SYSROOT}/usr/lib/gopath" \
		$(tc-getGO) "$@" || die
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

cros-go_src_install() {
	local workspace="${CROS_GO_WORKSPACE:-${S}}"

	local bin
	for bin in "${CROS_GO_BINARIES[@]}" ; do
		local name="${bin##*/}"
		name="${name#*:}"
		dobin "${name}"
	done

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
}

EXPORT_FUNCTIONS src_compile src_install
