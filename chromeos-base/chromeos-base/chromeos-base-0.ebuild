# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

inherit useradd

DESCRIPTION="ChromeOS specific system setup"
HOMEPAGE="http://src.chromium.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="cros_host"

DEPEND=">=sys-apps/baselayout-2"
RDEPEND="${DEPEND}
	!<sys-apps/baselayout-2.0.1-r227
	!<sys-libs/timezone-data-2011d"

# Remove entry from /etc/group
#
# $1 - Group name
remove_group() {
	[ -e "${ROOT}/etc/group" ] && sed -i -e /^${1}:.\*$/d "${ROOT}/etc/group"
}

# Adds a "daemon"-type user with no login or shell.
copy_or_add_daemon_user() {
	local username="$1"
	local uid="$2"
	if user_exists "${username}"; then
		elog "Removing existing user '$1' for copy_or_add_daemon_user"
		remove_user "${username}"
	fi
	copy_or_add_user "${username}" "*" $uid $uid "" /dev/null /bin/false

	if group_exists "${username}"; then
		elog "Removing existing group '$1' for copy_or_add_daemon_user"
		elog "Any existing group memberships will be lost"
		remove_group "${username}"
	fi
	copy_or_add_group "${username}" $uid
}

# Removes all users from a group in /etc/group.
# No changes if the group does not exist.
remove_all_users_from_group() {
	local group="$1"
	sed -i "/^${group}:/s/:[^:]*$/:/" "${ROOT}/etc/group"
}

# Removes a list of users from a group in /etc/group.
# No changes if the group does not exist or the user is not in the group.
remove_users_from_group() {
	local group="$1"; shift
	local username
	for username in "$@"; do
		sed -i -r "/^${group}:/{s/([,:])${username}(,|$)/\1/; s/,$//}" \
			"${ROOT}/etc/group"
	done
}

# Adds a list of users to a group in /etc/group.
# No changes if the group does not exist.
add_users_to_group() {
	local group="$1"; shift
	local username
	remove_users_from_group "${group}" "$@"
	for username in "$@"; do
		sed -i "/^${group}:/{ s/$/,${username}/ ; s/:,/:/ }" "${ROOT}/etc/group"
	done
}

pkg_setup() {
	if ! use cros_host ; then
		# The sys-libs/timezone-data package installs a default /etc/localtime
		# file automatically, so scrub that if it's a regular file.
		local etc_tz="${ROOT}etc/localtime"
		[[ -L ${etc_tz} ]] || rm -f "${etc_tz}"
	fi
}

src_install() {
	insinto /etc
	doins "${FILESDIR}"/sysctl.conf || die

	insinto /etc/profile.d
	doins "${FILESDIR}"/xauthority.sh || die

	# target-specific fun
	if ! use cros_host ; then
		# Symlink /etc/localtime to something on the stateful partition, which we
		# can then change around at runtime.
		dosym /var/lib/timezone/localtime /etc/localtime || die
	fi
}

pkg_postinst() {
	local x

	# We explicitly add all of the users needed in the system here. The
	# build of Chromium OS uses a single build chroot environment to build
	# for various targets with distinct ${ROOT}. This causes two problems:
	#   1. The target rootfs needs to have the same UIDs as the build
	#      chroot so that chmod operations work.
	#   2. The portage tools to add a new user in an ebuild don't work when
	#      $ROOT != /
	# We solve this by having baselayout install in both the build and
	# target and pre-create all needed users. In order to support existing
	# build roots we copy over the user entries if they already exist.
	local system_user="chronos"
	local system_id="1000"
	local system_home="/home/${system_user}/user"
	# Add a chronos-access group to provide non-chronos users,
	# mostly system daemons running as a non-chronos user, group permissions
	# to access files/directories owned by chronos.
	local system_access_user="chronos-access"
	local system_access_id="1001"

	local crypted_password='*'
	[ -r "${SHARED_USER_PASSWD_FILE}" ] &&
		crypted_password=$(cat "${SHARED_USER_PASSWD_FILE}")
	remove_user "${system_user}"
	add_user "${system_user}" "x" "${system_id}" \
		"${system_id}" "system_user" "${system_home}" /bin/sh
	remove_shadow "${system_user}"
	add_shadow "${system_user}" "${crypted_password}"

	copy_or_add_group "${system_user}" "${system_id}"
	copy_or_add_daemon_user "${system_access_user}" "${system_access_id}"
	copy_or_add_daemon_user "messagebus" 201  # For dbus
	copy_or_add_daemon_user "syslog" 202      # For rsyslog
	copy_or_add_daemon_user "ntp" 203
	copy_or_add_daemon_user "sshd" 204
	copy_or_add_daemon_user "pulse" 205       # For pulseaudio
	copy_or_add_daemon_user "polkituser" 206  # For policykit
	copy_or_add_daemon_user "tss" 207         # For trousers (TSS/TPM)
	copy_or_add_daemon_user "pkcs11" 208      # For opencryptoki
	copy_or_add_daemon_user "qdlservice" 209  # for QDLService
	copy_or_add_daemon_user "cromo" 210       # For cromo (modem manager)
	copy_or_add_daemon_user "cashew" 211      # For cashew (network usage)
	copy_or_add_daemon_user "ipsec" 212       # For strongswan/ipsec VPN
	copy_or_add_daemon_user "cros-disks" 213  # For cros-disks
	copy_or_add_daemon_user "tor" 214         # For tor (anonymity service)
	copy_or_add_daemon_user "tcpdump" 215     # For tcpdump --with-user
	# Reserve some UIDs/GIDs between 300 and 349 for sandboxing FUSE-based
	# filesystem daemons.
	copy_or_add_daemon_user "ntfs-3g" 300     # For ntfs-3g prcoess
	copy_or_add_daemon_user "avfs" 301        # For avfs process

	# The system_user needs to be part of the audio and video groups.
	add_users_to_group audio "${system_user}"
	add_users_to_group video "${system_user}"

	# The root, ipsec and ${system_user} users must be in the pkcs11 group,
	# which must have the group id 208.
	remove_all_users_from_group pkcs11
	add_users_to_group pkcs11 root ipsec "${system_user}"
	# TODO(benchan): Is it still true that pkcs11 must have a group id 208?
	# If so, we should better enforce that in copy_or_add_daemon_user and
	# error out if another group is already assigned the group id 208.
	sed -i "s/^\(pkcs11:[^:]*\):[^:]\+:/\1:208:/" "${ROOT}/etc/group"

	# All users in the pkcs11 group and all users for sandboxing FUSE-based
	# filesystem daemons need to be in the ${system_access_user} group,
	remove_all_users_from_group "${system_access_user}"
	add_users_to_group "${system_access_user}" root ipsec "${system_user}" \
		ntfs-3g avfs

	# Some default directories. These are created here rather than at
	# install because some of them may already exist and have mounts.
	for x in /dev /home /media \
		/mnt/stateful_partition /proc /root /sys /var/lock; do
		[ -d "${ROOT}/$x" ] && continue
		install -d --mode=0755 --owner=root --group=root "${ROOT}/$x"
	done

	# We add an entry for www35.vzw.com to /etc/hosts to work around bug
	# http://crosbug.com/p/4279
	cat <<-EOF >> "${ROOT}"/etc/hosts

	# http://crosbug.com/p/4279
	127.0.0.1	www35.vzw.com
	EOF
}
