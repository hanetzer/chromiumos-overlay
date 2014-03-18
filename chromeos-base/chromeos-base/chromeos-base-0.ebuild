# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

inherit pam useradd user

DESCRIPTION="ChromeOS specific system setup"
HOMEPAGE="http://src.chromium.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="cros_embedded cros_host pam"

# We need to make sure timezone-data is merged before us.
# See pkg_setup below as well as http://crosbug.com/27413
# and friends.
# Similarly, we have to make sure bash is merged before us.
# We don't need dash because only bash modifies ROOT duing
# pkg_* stages, and depending on dash would disable a little
# bit of possible parallelism.
# See http://crosbug.com/38597 for more details.
DEPEND=">=sys-apps/baselayout-2
	!<sys-apps/baselayout-2.0.1-r227
	!<sys-libs/timezone-data-2011d
	!<=app-admin/sudo-1.8.2
	!<sys-apps/mawk-1.3.4
	!<app-shells/bash-4.1
	!<app-shells/dash-0.5.5
	!<net-misc/openssh-5.2_p1-r8
	!<chromeos-base/chromeos-init-0.0.17
	!cros_host? (
		!pam? (
			!app-admin/sudo
		)
		!app-misc/editor-wrapper
		!cros_embedded? (
			app-shells/bash
		)
		sys-libs/timezone-data
	)"
RDEPEND="${DEPEND}"

S="${WORKDIR}"

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
	doins "${FILESDIR}"/issue

	insinto /etc/profile.d
	doins "${FILESDIR}"/xauthority.sh || die

	insinto /lib/udev/rules.d
	doins "${FILESDIR}"/udev-rules/*.rules || die

	insinto /etc/avahi
	doins "${FILESDIR}"/avahi-daemon.conf || die

	# target-specific fun
	if ! use cros_host ; then
		dodir /bin /usr/bin

		# Symlink /etc/localtime to something on the stateful partition, which we
		# can then change around at runtime.
		dosym /var/lib/timezone/localtime /etc/localtime || die

		# We use mawk in the target boards, not gawk.
		dosym mawk /usr/bin/awk || die

		# We want dash as our main shell.
		dosym dash /bin/sh

		# Avoid the wrapper and just link to the only editor we have.
		dodir /usr/libexec
		dosym /usr/bin/$(usex cros_embedded vi vim) /usr/libexec/editor || die
		dosym /bin/more /usr/libexec/pager || die

		# Install our custom ssh config settings.
		insinto /etc/ssh
		doins "${FILESDIR}"/ssh{,d}_config
		fperms 600 /etc/ssh/sshd_config

		if ! use pam ; then
			dobin "${FILESDIR}"/sudo
			sed -i -e '/^UsePAM/d' "${D}"/etc/ssh/sshd_config || die
		fi

		# Custom login shell snippets.
		insinto /etc/profile.d
		doins "${FILESDIR}"/cursor.sh
	fi

	# Some daemons and utilities access the mounts through /etc/mtab.
	dosym /proc/mounts /etc/mtab || die

	# Add our little bit of sudo glue.
	newpamd "${FILESDIR}"/include-chromeos-auth sudo
	# This one line comes from the sudo ebuild.
	pamd_mimic system-auth sudo auth account session
	if [[ -n ${SHARED_USER_NAME} ]] ; then
		insinto /etc/sudoers.d
		echo "${SHARED_USER_NAME} ALL=(ALL) ALL" > 95_cros_base
		insopts -m 440
		doins 95_cros_base || die
	fi
}

pkg_postinst() {
	local x group_lock passwd_lock
	# This is temporary until we complete http://crbug.com/343369
	group_lock=$(readlink -e "${ROOT}/etc/group").lock
	passwd_lock=$(readlink -e "${ROOT}/etc/passwd").lock
	_portable_grab_lock "${group_lock}"
	_portable_grab_lock "${passwd_lock}"

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
		"${system_id}" "system_user" "${system_home}" /bin/bash
	remove_shadow "${system_user}"
	add_shadow "${system_user}" "${crypted_password}"

	copy_or_add_group "${system_user}" "${system_id}"
	copy_or_add_daemon_user "${system_access_user}" "${system_access_id}"
	copy_or_add_daemon_user "messagebus" 201  # For dbus
	copy_or_add_daemon_user "syslog" 202      # For rsyslog
	copy_or_add_daemon_user "ntp" 203
	copy_or_add_daemon_user "sshd" 204
	copy_or_add_daemon_user "polkituser" 206  # For policykit
	copy_or_add_daemon_user "tss" 207         # For trousers (TSS/TPM)
	copy_or_add_daemon_user "pkcs11" 208      # For pkcs11 clients
	copy_or_add_daemon_user "qdlservice" 209  # for QDLService
	copy_or_add_daemon_user "cromo" 210       # For cromo (modem manager)
#	copy_or_add_daemon_user "cashew" 211      # Deprecated, do not reuse
	copy_or_add_daemon_user "ipsec" 212       # For strongswan/ipsec VPN
	copy_or_add_daemon_user "cros-disks" 213  # For cros-disks
	copy_or_add_daemon_user "tor" 214         # For tor (anonymity service)
	copy_or_add_daemon_user "tcpdump" 215     # For tcpdump --with-user
	copy_or_add_daemon_user "debugd" 216      # For debugd
	copy_or_add_daemon_user "openvpn" 217     # For openvpn
	copy_or_add_daemon_user "bluetooth" 218   # For bluez
	copy_or_add_daemon_user "wpa" 219         # For wpa_supplicant
	copy_or_add_daemon_user "cras" 220        # For cras (audio)
#	copy_or_add_daemon_user "gavd" 221        # For gavd (audio) (deprecated)
	copy_or_add_daemon_user "input" 222       # For /dev/input/event access
	copy_or_add_daemon_user "chaps" 223       # For chaps (pkcs11)
	copy_or_add_daemon_user "dhcp" 224        # For dhcpcd (DHCP client)
	copy_or_add_daemon_user "tpmd" 225        # For tpmd
	copy_or_add_daemon_user "mtp" 226         # For libmtp
	copy_or_add_daemon_user "proxystate" 227  # For proxy monitoring
	copy_or_add_daemon_user "power" 228       # For powerd
	copy_or_add_daemon_user "watchdog" 229    # For daisydog
	copy_or_add_daemon_user "devbroker" 230   # For permission_broker
	copy_or_add_daemon_user "xorg" 231        # For Xorg
	copy_or_add_daemon_user "nfqueue" 232     # For netfilter-queue
	copy_or_add_daemon_user "tlsdate-dbus" 233 # For tlsdate-dbus-announce
	copy_or_add_daemon_user "tlsdate" 234
	copy_or_add_daemon_user "debugd-logs" 235 # For debugd's unprivileged logs
	copy_or_add_daemon_user "debugfs-access" 236 # Access to debugfs
	copy_or_add_daemon_user "shill-crypto" 237 # For shill's crypto-util
	copy_or_add_daemon_user "avahi" 238       # For avahi-daemon
	copy_or_add_daemon_user "p2p" 239         # For p2p
	copy_or_add_daemon_user "brltty" 240      # For braille displays
	copy_or_add_daemon_user "modem" 241       # For modem manager
	# Reserve some UIDs/GIDs between 300 and 349 for sandboxing FUSE-based
	# filesystem daemons.
	copy_or_add_daemon_user "ntfs-3g" 300     # For ntfs-3g prcoess
	copy_or_add_daemon_user "avfs" 301        # For avfs process
	copy_or_add_daemon_user "fuse-exfat" 302  # For exfat-fuse prcoess

	# Group that is allowed to create directories under /home/root/<hash>.
	copy_or_add_group "daemon-store" 400
	copy_or_add_group "logs-access" 401

	# All audio interfacing will go through the audio server.
	add_users_to_group audio "cras"
	add_users_to_group input "cras"           # For /dev/input/event* access

	# The system user is part of the audio server group to play sounds.  The
	# power manager user needs to check whether audio is playing.
	add_users_to_group cras "${system_user}" power

	# The system_user needs to be part of the audio and video groups.
	add_users_to_group audio "${system_user}"
	add_users_to_group video "${system_user}"

	# The Xorg user needs to be part of the input, video and tty groups.
	add_users_to_group input "xorg"
	add_users_to_group video "xorg"
	add_users_to_group tty "xorg"

	# Users which require access to PKCS #11 cryptographic services must be
	# in the pkcs11 group.
	remove_all_users_from_group pkcs11
	add_users_to_group pkcs11 root ipsec "${system_user}" chaps wpa

	# All users accessing opencryptoki database files and all users for
	# sandboxing FUSE-based filesystem daemons need to be in the
	# ${system_access_user} group.
	remove_all_users_from_group "${system_access_user}"
	add_users_to_group "${system_access_user}" root ipsec "${system_user}" \
		ntfs-3g avfs fuse-exfat chaps

	# Dedicated group for owning access to serial devices.
	copy_or_add_group "serial" 402
	add_users_to_group "serial" "${system_user}"
	add_users_to_group "serial" "uucp"

	# debugd-logs has logs access
	add_users_to_group "logs-access" "debugd-logs"

	# The root user must be in the wpa group for wpa_cli.
	add_users_to_group wpa root

	# Restrict tcsd access to root and chaps.
	add_users_to_group tss root chaps

	# Add mtp user to usb group for USB device access.
	add_users_to_group usb mtp

	# Create a group for device access via permission_broker
	copy_or_add_group "devbroker-access" 403
	add_users_to_group devbroker-access "${system_user}"

	# Give the power manager access to I2C devices so it can adjust external
	# displays' brightness via DDC.
	copy_or_add_group i2c 404
	add_users_to_group i2c power

	# Give the power manager access to /dev/tty* so it can disable VT switching
	# before suspending the system.
	add_users_to_group tty power

	# The power manager needs to read from /dev/input/event* to observe power
	# button and lid events.
	add_users_to_group input power

	# Chaps needs access to the daemon-store.
	add_users_to_group "daemon-store" chaps

	# brltty needs access to usb and tty devices.
	add_users_to_group usb brltty
	add_users_to_group tty brltty

	# The system_user needs to access braille displays.
	add_users_to_group brltty ${system_user}

	rm "${group_lock}" || die "Failed to release lock on ${group_lock}"
	rm "${passwd_lock}"  || die "Failed to release lock on ${passwd_lock}"

	# Some default directories. These are created here rather than at
	# install because some of them may already exist and have mounts.
	for x in /dev /home /media \
		/mnt/stateful_partition /proc /root /sys /var/lock; do
		[ -d "${ROOT}/$x" ] && continue
		install -d --mode=0755 --owner=root --group=root "${ROOT}/$x"
	done

	# On embedded systems, we don't have bash.  So use /bin/sh.
	if use cros_embedded; then
		sed -i \
			-e '/:\/bin\/bash$/s:bash$:sh:' \
			"${ROOT}"/etc/passwd || die
	fi
}
