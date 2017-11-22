# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="fedb675ed52b8e54f78d80b9938c98746e888b37"
CROS_WORKON_TREE="7a74e1e14a3552138119687ba0213c8d543c3972"
CROS_WORKON_PROJECT="chromiumos/platform/crosvm"
CROS_WORKON_LOCALNAME="../platform/crosvm"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_OUTOFTREE_BUILD=1

CRATES="
byteorder-1.1.0
libc-0.2.32
gcc-0.3.54
"

inherit cargo cros-workon toolchain-funcs user

DESCRIPTION="Utility for running Linux VMs on Chrome OS"

SRC_URI="$(cargo_crate_uris ${CRATES})"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="debug"

RDEPEND="chromeos-base/minijail
	!chromeos-base/crosvm-bin"
DEPEND="${RDEPEND}"

src_unpack() {
	# Unpack both the project and dependency source code
	cargo_src_unpack
	cros-workon_src_unpack
}

src_test() {
	export CARGO_HOME="${ECARGO_HOME}"
	export TARGET_CC="$(tc-getCC)"
	export CARGO_TARGET_DIR="${WORKDIR}"

	if ! use x86 && ! use amd64 ; then
		elog "Skipping unit tests on non-x86 platform"
	else
		cargo test --all \
			--exclude kvm \
			--exclude kvm_sys \
			--exclude net_util -v \
			--target="${CHOST}" -- --test-threads=1 \
			|| die "cargo test failed"
	fi
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

pkg_preinst() {
	enewuser "crosvm"
	enewgroup "crosvm"
}
