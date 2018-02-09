# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT=("42673c8e89e0e8bcf848eccff16f6b454d087646" "b3f119ac2f8dbb79fba8d34c5e471ed2e8d0ef19")
CROS_WORKON_TREE=("444cc94c82f80a12e2f78d985c6a5d35e4eda33a" "a84b23343bd93df2ed40a402d5ce64000e56b71c")
CROS_WORKON_PROJECT=(
	"chromiumos/platform2"
	"chromiumos/platform/mosys"
)

CROS_WORKON_LOCALNAME=(
	"../platform2"
	"../platform/mosys"
)

CROS_WORKON_DESTDIR=(
	"${S}/platform2"
	"${S}/platform/mosys"
)

PLATFORM_SUBDIR="mosys"

inherit flag-o-matic toolchain-funcs cros-unibuild cros-workon platform

DESCRIPTION="Utility for obtaining various bits of low-level system info"
HOMEPAGE="http://mosys.googlecode.com/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="static unibuild"

# We need util-linux for libuuid.
RDEPEND="unibuild? (
		chromeos-base/chromeos-config
		sys-apps/dtc
	)
	sys-apps/util-linux
	>=sys-apps/flashmap-0.3-r4"
DEPEND="${RDEPEND}"

src_unpack() {
	local s="${S}"
	platform_src_unpack
	# The platform eclass will look for mosys in src/platform2 This forces it
	# to look in src/platform.
	S="${s}/platform/mosys"
}

src_configure() {
	# Generate a default .config for our target architecture.
	einfo "using default configuration for $(tc-arch)"
	ARCH=$(tc-arch) emake defconfig
	tc-export AR CC LD PKG_CONFIG
	export LDFLAGS="$(raw-ldflags)"

	if use unibuild; then
		cp "${SYSROOT}${UNIBOARD_DTB_INSTALL_PATH}" \
			lib/cros_config/config.dtb
		echo "CONFIG_CROS_CONFIG=y" >>.config
	fi
}

src_compile() {
	emake
}

platform_pkg_test() {
	if use unibuild; then
		echo "CONFIG_TEST=y" >>.config
		ARCH=$(tc-arch) emake simple_tests

		platform_test "run" "${S}/simple_tests"
	fi
}

src_install() {
	dosbin mosys

	# Install the optional static binary if supported.
	use static && dosbin mosys_s

	dodoc README TODO
}
