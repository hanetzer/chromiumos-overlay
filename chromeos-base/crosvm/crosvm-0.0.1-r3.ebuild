# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="bb493dd02b4dd9efde179f0c4372c006d308da5a"
CROS_WORKON_TREE="cbf4143c93e44f4766c5c65dfe29533802a3c866"
CROS_WORKON_PROJECT="chromiumos/platform/crosvm"
CROS_WORKON_LOCALNAME="../platform/crosvm"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_OUTOFTREE_BUILD=1

CRATES="
byteorder-1.1.0
libc-0.2.29
gcc-0.3.54
"

inherit cargo cros-workon

DESCRIPTION="Utility for running Linux VMs on Chrome OS"

SRC_URI="$(cargo_crate_uris ${CRATES})"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="debug"

RDEPEND="chromeos-base/chromeos-minijail"
DEPEND="${RDEPEND}"

src_unpack() {
	# Unpack both the project and dependency source code
	cargo_src_unpack
	cros-workon_src_unpack
}

src_install() {
	local seccomp_arch="unknown"
	case ${ARCH} in
		amd64) seccomp_arch=x86_64;;
	esac

	# cargo doesn't know how to install cross-compiled binaries.  It will
	# always install native binaries for the host system.  Manually install
	# crosvm instead.
	dobin "${WORKDIR}/${CHOST}/$(usex debug debug release)/crosvm"

	# Install seccomp policy files.
	local seccomp_path="${S}/seccomp/${seccomp_arch}"
	if [[ -d "${seccomp_path}" ]] ; then
		insinto /usr/share/policy/crosvm
		doins "${seccomp_path}"/*.policy
	fi
}
