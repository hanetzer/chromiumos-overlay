# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

PYTHON_COMPAT=( python2_7 )

inherit python-any-r1 versionator toolchain-funcs

if [[ ${PV} == *beta* ]]; then
	betaver=${PV//*beta}
	BETA_SNAPSHOT="${betaver:0:4}-${betaver:4:2}-${betaver:6:2}"
	MY_P="rustc-beta"
	SLOT="beta/${PV}"
	SRC="${BETA_SNAPSHOT}/rustc-beta-src.tar.gz"
else
	ABI_VER="$(get_version_component_range 1-2)"
	SLOT="stable/${ABI_VER}"
	MY_P="rustc-${PV}"
	SRC="${MY_P}-src.tar.gz"
fi

CARGO_VERSION="0.$(($(get_version_component_range 2) + 1)).0"
STAGE0_VERSION="1.$(($(get_version_component_range 2) - 1)).0"
RUST_STAGE0_amd64="rustc-${STAGE0_VERSION}-x86_64-unknown-linux-gnu"

DESCRIPTION="Systems programming language from Mozilla"
HOMEPAGE="http://www.rust-lang.org/"
SRC_URI="https://static.rust-lang.org/dist/${SRC} -> rustc-${PV}-src.tar.gz
	https://static.rust-lang.org/dist/${RUST_STAGE0_amd64}.tar.gz
"

LICENSE="|| ( MIT Apache-2.0 ) BSD-1 BSD-2 BSD-4 UoI-NCSA"
IUSE="jemalloc clang debug doc libcxx"
RESTRICT="binchecks strip"
REQUIRED_USE="libcxx? ( clang )"
# We rely on a prebuilt binary to bootstrap, so only support amd64 atm.
KEYWORDS="-* amd64"

RDEPEND="libcxx? ( sys-libs/libcxx )"

DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	>=dev-lang/perl-5.0
	clang? ( sys-devel/clang )
"

PATCHES=(
	"${FILESDIR}"/0001-fix-target-armv7a-cros.patch
	"${FILESDIR}"/0002-add-target-armv7a-cros-linux.patch
	"${FILESDIR}"/0003-fix-unknown-vendors.patch
)

S="${WORKDIR}/${MY_P}-src"

src_prepare() {
	find mk -name '*.mk' -exec \
		sed -i -e "s/-Werror / /g" {} + || die

	# The following config script changes are here so that the rust
	# bootstrapping process can find the toolchain for each target we are
	# building for. The armv7 config is particularly complicated because
	# the upstream triple differs in more ways than just the vendor
	# string: the architecture and ABI are also different.
	cd mk/cfg
	sed -e 's:armv7-unknown-linux-gnueabihf:armv7a-cros-linux-gnueabi:g' \
		-e 's:arm-linux-gnueabihf-:armv7a-cros-linux-gnueabi-:g'  \
		-e 's:-unknown-linux-gnueabihf:-cros-linux-gnueabi:g' \
		armv7-unknown-linux-gnueabihf.mk >armv7a-cros-linux-gnueabi.mk || die
	sed -e 's:unknown:cros:g' \
		-e 's:aarch64-linux-gnu-:aarch64-cros-linux-gnu-:g' \
		aarch64-unknown-linux-gnu.mk >aarch64-cros-linux-gnu.mk || die
	sed 's:unknown:pc:g' x86_64-unknown-linux-gnu.mk >x86_64-pc-linux-gnu.mk || die
	sed 's:unknown:cros:g' x86_64-unknown-linux-gnu.mk >x86_64-cros-linux-gnu.mk || die
	cd ../..

	# armv7a is treated specially because the cros toolchain differs in
	# more than just the vendor part of the target triple. The arch is
	# armv7a in cros versus armv7 and the abi is gnueabi in cros verus
	# gnueabihf. This should no longer be needed after crbug.com/711369
	# is fixed.
	cd src/librustc_back/target
	sed 's:"unknown":"cros":g' armv7_unknown_linux_gnueabihf.rs >armv7a_cros_linux_gnueabi.rs || die
	cd ../../..

	epatch "${PATCHES[@]}"

	default
}

src_configure() {
	export CFG_DISABLE_LDCONFIG="notempty"

	local stagename="RUST_STAGE0_${ARCH}"
	local stage0="${!stagename}"
	local targets="x86_64-cros-linux-gnu,armv7a-cros-linux-gnueabi,aarch64-cros-linux-gnu,x86_64-pc-linux-gnu"

	"${ECONF_SOURCE:-.}"/configure \
		--prefix="${EPREFIX}/usr" \
		--libdir="${EPREFIX}/usr/$(get_libdir)/rust/" \
		--mandir="${EPREFIX}/usr/share/man" \
		--release-channel=${SLOT%%/*} \
		--disable-manage-submodules \
		--disable-rustbuild \
		--disable-docs \
		--default-linker="$(tc-getBUILD_CC)" \
		--default-ar="$(tc-getBUILD_AR)" \
		--python="${EPYTHON}" \
		--enable-local-rust \
		--local-rust-root="${WORKDIR}/${stage0}/rustc" \
		--target="${targets}" \
		$(use_enable jemalloc) \
		$(use_enable clang) \
		$(use_enable debug) \
		$(use_enable debug llvm-assertions) \
		$(use_enable !debug optimize) \
		$(use_enable !debug optimize-cxx) \
		$(use_enable !debug optimize-llvm) \
		$(use_enable !debug optimize-tests) \
		$(use_enable doc docs) \
		$(use_enable libcxx libcpp) \
		|| die
}

src_compile() {
	emake VERBOSE=1
}

src_install() {
	# The install process erroneously assumes we are root if this is set.
	# SUDO_USER is often inherited when entering the cros chroot, which
	# uses sudo under the hood before dropping down to a regular user.
	unset SUDO_USER

	default
}
