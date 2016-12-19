# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

DESCRIPTION="Chrome OS Fonts (meta package)"
HOMEPAGE="http://src.chromium.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="cros_host internal"

# Internal and external builds deliver different fonts for Japanese.
# Although the two fonts can in theory co-exist, the font selection
# code in the chromeos-initramfs build prefers one or the other, but
# not both.
#
# The build system will actually try to make both fonts co-exist in
# some cases, because the default chroot downloaded by cros_sdk
# includes the ja-ipafonts package.  The logic here also protects
# in the case that you switch a repo from internal to external, and
# vice-versa.
JA_FONTS="
	internal? (
		chromeos-base/ja-motoyafonts
		!media-fonts/ja-ipafonts
	)
	!internal? (
		!chromeos-base/ja-motoyafonts
		media-fonts/ja-ipafonts
	)
	"

# List of font packages used in Chromium OS.  This list is separate
# so that it can be shared between the host in
# chromeos-base/hard-host-depends and the target in
# chromeos-base/chromeos.
#
# The glibc requirement is a bit funky.  For target boards, we make sure it is
# installed before any other package (by way of setup_board), but for the sdk
# board, we don't have that toolchain-specific tweak.  So we end up installing
# these in parallel and the chroot logic for font generation fails.  We can
# drop this when we stop executing the helper in the $ROOT via `chroot` and/or
# `qemu` (e.g. when we do `ROOT=/build/amd64-host/ emerge chromeos-fonts`).
#
# The gcc-libs requirement is a similar situation.  Ultimately this comes down
# to fixing http://crbug.com/205424.
RDEPEND="
	${JA_FONTS}
	internal? ( chromeos-base/ascender_to_license )
	media-fonts/croscorefonts
	media-fonts/crosextrafonts
	media-fonts/crosextrafonts-carlito
	media-fonts/noto-cjk
	media-fonts/notofonts
	media-fonts/dejavu
	media-fonts/droidfonts-cros
	media-fonts/ko-nanumfonts
	media-fonts/lohitfonts-cros
	media-fonts/ml-anjalioldlipi
	media-fonts/robotofonts
	media-fonts/sil-abyssinica
	media-fonts/tibt-jomolhari
	media-libs/fontconfig
	!cros_host? ( sys-libs/gcc-libs )
	cros_host? ( sys-libs/glibc )
	"

qemu_run() {
	# Run the emulator to execute command. It needs to be copied
	# temporarily into the sysroot because we chroot to it.
	local qemu=()
	case "${ARCH}" in
		amd64)
			# Note that qemu is not actually run below in this case.
			qemu=( qemu-x86_64 -cpu Broadwell )
			;;
		arm)
			qemu=( qemu-arm )
			;;
		arm64)
			qemu=( qemu-aarch64 )
			;;
		mips)
			qemu=( qemu-mipsel )
			;;
		x86)
			qemu=( qemu-i386 -cpu Broadwell )
			;;
		*)
			die "Unable to determine QEMU from ARCH."
	esac

	# If we're running directly on the target (e.g. gmerge), we don't need to
	# chroot or use qemu.
	if [ "${ROOT:-/}" = "/" ]; then
		"$@" || die
	else
		# Try to run it natively first as it should be fast.
		if [ "${ARCH}" = "amd64" ] || [ "${ARCH}" = "x86" ]; then
			if chroot "${ROOT}" "$@" ; then
				return
			fi
			ewarn "Native crashed; falling back to qemu"
		fi
		cp "/usr/bin/${qemu[0]}" "${ROOT}/tmp" || die
		chroot "${ROOT}" "/tmp/${qemu[0]}" "${qemu[@]:1}" "$@" || die
		rm "${ROOT}/tmp/${qemu[0]}" || die
	fi
}

generate_font_cache() {
	mkdir -p "${ROOT}/usr/share/fontconfig" || die
	# fc-cache needs the font files to be located in their final resting place.
	qemu_run /usr/bin/fc-cache -f -v
}

pkg_preinst() {
	# We don't bother updating the cache in the sysroot since it's only needed
	# by the runtime.  This does mean any tools that are run in the sysroot will
	# also be slow, but we don't know of any like that today.
	# https://crbug.com/205424
	if [[ "$(cros_target)" == "target_image" ]]; then
		generate_font_cache
	else
		einfo "Skipping build-time-only font cache generation. https://crbug.com/205424"
	fi
}
