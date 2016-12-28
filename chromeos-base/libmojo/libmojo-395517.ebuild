# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

inherit cros-debug libchrome multilib toolchain-funcs

DESCRIPTION="Mojo library"
# TODO(ejcaruso): libmojo is in AOSP but the current version will
# cause version mismatches. Remove this when libchrome updates.
SRC_URI="gs://chromeos-localmirror/distfiles/${P}.tgz"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_compile() {
	if [[ "${PV}" != "${LIBCHROME_VERS}" ]]; then
		die "Version mismatch"
	fi
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG
	emake templates
	emake BASE_VER="${LIBCHROME_VERS}" LIB="$(get_libdir)"
}

src_install() {
	default

	local d header_dirs=(
		build
		ipc
		mojo/android/system
		mojo/common
		mojo/converters/blink
		mojo/converters/geometry
		mojo/converters/ime
		mojo/converters/input_events
		mojo/converters/surfaces
		mojo/converters/transform
		mojo/edk/embedder
		mojo/edk/js
		mojo/edk/system
		mojo/edk/system/ports
		mojo/gles2
		mojo/gpu
		mojo/logging
		mojo/message_pump
		mojo/platform_handle
		mojo/public/c/gles2
		mojo/public/c/system
		mojo/public/cpp/bindings
		mojo/public/cpp/bindings/lib
		mojo/public/cpp/system
		mojo/public/interfaces/bindings
		mojo/public/js
		mojo/public/platform/native
		mojo/util
	)
	for d in "${header_dirs[@]}" ; do
		insinto "/usr/include/libmojo-${PV}/${d}"
		doins "${d}"/*.h
	done

	insinto "/usr/$(get_libdir)/pkgconfig"
	doins "libmojo-${PV}.pc"
}
