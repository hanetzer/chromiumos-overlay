# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

#
# Original Author: The Chromium OS Authors <chromium-os-dev@chromium.org>
# Purpose: Library for supporting the Go programming language in Chromium OS.
#

# @ECLASS-VARIABLE: CROS_GO_WORKSPACE
# @DESCRIPTION:
# Path to the Go workspace, default is ${S}

# @ECLASS-VARIABLE: CROS_GO_PACKAGES
# @DESCRIPTION:
# Go packages to install in /usr/lib/gopath
# Package paths are relative to ${CROS_GO_WORKSPACE}/src
# Packages are installed in /usr/lib/gopath such that they
# can be imported later from Go code using the exact paths
# listed here. For example:
#   CROS_GO_PACKAGES=(
#     "chromiumos/seccomp"
#   )
# will install seccomp package files
#   from "${CROS_GO_WORKSPACE}/src/chromiumos/seccomp"
#   to "/usr/lib/gopath/src/chromiumos/seccomp"
# and other Go projects can use the package with
#   import "chromiumos/seccomp"

inherit toolchain-funcs

cros_go() {
	local workspace="${CROS_GO_WORKSPACE:-${S}}"
	GOPATH="${workspace}:${SYSROOT}/usr/lib/gopath" \
		$(tc-getGO) "$@" || die
}

cros-go_src_install() {
	local workspace="${CROS_GO_WORKSPACE:-${S}}"
	if [[ ${#CROS_GO_PACKAGES[@]} -gt 0 ]] ; then
		# Run in sub-shell so we do not modify env.
		(
			local pkg
			for pkg in "${CROS_GO_PACKAGES[@]}" ; do
				local srcdir="${workspace}/src/${pkg}"
				insinto "/usr/lib/gopath/src/${pkg}"

				if [[ ! -d "${srcdir}" ]] ; then
					die "Package not found: \"${pkg}\""
				fi

				local file
				while read -d $'\0' -r file ; do
					doins "${file}"
				done < <(find "${srcdir}" -maxdepth 1 ! -type d -print0)
			done
		)
	fi
}

EXPORT_FUNCTIONS src_install
