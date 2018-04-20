# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT="d7674b8d35dcb082e3a1c6e086536ad3066e5808"
CROS_WORKON_TREE=("99d4f98c0151c7e25437bb625f114bde347170d5" "001efce705e3f1646e096f68a3242840eea1b588" "a549f26cbe816655b9a765c1b9b779e3dba78f9a")
CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk arc/container-bundle arc/scripts"

inherit cros-workon user

DESCRIPTION="Container to run Android."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/arc/container-bundle"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

# TODO(b/73695883): Rename from android-container-master-arc-dev to
# android-container-master.
IUSE="
	android-container-master-arc-dev
	android-container-nyc
	android-container-pi
	"

RDEPEND="!<chromeos-base/chromeos-cheets-scripts-0.0.3"
DEPEND="${RDEPEND}"

CONTAINER_ROOTFS="/opt/google/containers/android/rootfs"

src_install() {
	insinto /opt/google/containers/android
	if use android-container-master-arc-dev; then
		doins arc/container-bundle/master/config.json
	elif use android-container-pi; then
		doins arc/container-bundle/pi/config.json
	elif use android-container-nyc; then
		doins arc/container-bundle/nyc/config.json
	else
		echo "Unknown container version" >&2
		exit 1
	fi

	# Install scripts.
	insinto /etc/init
	doins arc/scripts/arc-setfattr.conf
	doins arc/scripts/arc-stale-directory-remover.conf

	insinto /etc/sysctl.d
	doins arc/scripts/01-sysctl-arc.conf

	dosbin arc/scripts/android-sh
	dobin arc/scripts/collect-cheets-logs

	# Install exception file for FIFO blocking policy on stateful partition.
	insinto /usr/share/cros/startup/fifo_exceptions
	doins arc/container-bundle/arc-fifo-exceptions.txt

	# Install exception file for symlink blocking policy on stateful partition.
	insinto /usr/share/cros/startup/symlink_exceptions
	doins arc/container-bundle/arc-symlink-exceptions.txt
}

pkg_preinst() {
	enewuser "wayland"
	enewgroup "wayland"
	enewuser "arc-bridge"
	enewgroup "arc-bridge"
	enewuser "android-root"
	enewgroup "android-root"
	enewgroup "arc-sensor"
}

# Creates dalvik-cache/ and its arch/ directory.
create_dalvik_cache_arch_dir() {
	local dalvik_cache_dir="${ROOT}${CONTAINER_ROOTFS}/android-data/data/dalvik-cache"

	install -d --mode=0555 --owner=root --group=root \
		"${dalvik_cache_dir}" || true

	# TODO(yusukes): Do not create x86_64 directory unless the board
	# actually supports 64bit container.
	case ${ABI} in
	amd64|x86)
		install -d --mode=0555 --owner=root --group=root \
			"${dalvik_cache_dir}/x86" || true
		install -d --mode=0555 --owner=root --group=root \
			"${dalvik_cache_dir}/x86_64" || true
		;;
	arm)
		install -d --mode=0555 --owner=root --group=root \
			"${dalvik_cache_dir}/arm" || true
		;;
	*)
		echo "Unsupported ABI: ${ABI}" >&2
		exit 1
		;;
	esac
}

pkg_postinst() {
	local root_uid=$(egetent passwd android-root | cut -d: -f3)
	local root_gid=$(egetent group android-root | cut -d: -f3)

	# Create a 0700 directory, and then a subdirectory mount point.
	# These are created here rather than at
	# install because some of them may already exist and have mounts.
	install -d --mode=0700 --owner=${root_uid} --group=${root_gid} \
		"${ROOT}${CONTAINER_ROOTFS}" \
		|| true
	install -d --mode=0700 --owner=${root_uid} --group=${root_gid} \
		"${ROOT}${CONTAINER_ROOTFS}/root" \
		|| true
	install -d --mode=0755 --owner=root --group=root \
		"${ROOT}${CONTAINER_ROOTFS}/android-data" \
		|| true

	# Create /cache and /data directories. These are used when the container
	# is started for login screen as empty and readonly directories. To make
	# the directory not writable from the container even when / is remounted
	# with 'rw', use host's root as --owner and --group.
	install -d --mode=0555 --owner=root --group=root \
		"${ROOT}${CONTAINER_ROOTFS}/android-data/cache" \
		|| true
	install -d --mode=0555 --owner=root --group=root \
		"${ROOT}${CONTAINER_ROOTFS}/android-data/data" \
		|| true

	# master also needs /data/cache as a mount point. To make images look
	# similar, do the same for N too.
	install -d --mode=0555 --owner=root --group=root \
		"${ROOT}${CONTAINER_ROOTFS}/android-data/data/cache" \
		|| true

	# Create /data/dalvik-cache/<arch> directory so that we can start zygote
	# for the login screen.
	create_dalvik_cache_arch_dir
}
