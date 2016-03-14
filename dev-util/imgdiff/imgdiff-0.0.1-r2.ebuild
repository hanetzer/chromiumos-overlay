# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="38234f4bef8b70d985c09224e6d7752d71400f23"
CROS_WORKON_TREE="76b0016e92d7ec15a0287cfbfa7be13a5d6aee36"
CROS_WORKON_BLACKLIST=1
# cros-workon expects the repo to be in src/third_party, but is in src/aosp.
CROS_WORKON_LOCALNAME="../aosp/bootable/recovery"
CROS_WORKON_PROJECT="platform/bootable/recovery"
CROS_WORKON_REPO="https://android.googlesource.com"
CROS_WORKON_INCREMENTAL_BUILD=1

inherit cros-workon toolchain-funcs

DESCRIPTION="Construct binary patches for images that contain gzipped data."
HOMEPAGE="https://android.googlesource.com/platform/bootable/recovery"
SRC_URI=""

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="app-arch/bzip2
	dev-libs/openssl
	sys-libs/zlib"
DEPEND="${RDEPEND}"

src_configure() {
	tc-export AR CXX
}

src_compile() {
	emake -C applypatch
}

src_install() {
	cd applypatch

	dobin imgdiff

	dolib.a libimgpatch.a

	insinto /usr/include/applypatch
	doins include/applypatch/imgpatch.h

	insinto /usr/$(get_libdir)/pkgconfig
	doins libimgpatch.pc
}

pkg_preinst() {
	# We want imgdiff in the sdk and in the sysroot (for testing), but
	# we don't want it in the target image as it isn't used.
	if [[ $(cros_target) == "target_image" ]]; then
		rm "${D}"/usr/bin/imgdiff || die
	fi
}
