# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT=("8dd4e70812b7d49f5e47c0589d7d85aed652b97c" "08eebbdba6ab593a1fad1ee44e34bf41ffcbda68")
CROS_WORKON_TREE=("e1372f6e545d136d7591902707c779e31c200ed7" "6475b90977e020bb340c436be3a714f24161b778")
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
