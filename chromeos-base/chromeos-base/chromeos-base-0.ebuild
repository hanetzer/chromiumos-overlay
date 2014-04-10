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
		cros_embedded? (
			app-shells/dash
		)
		sys-libs/timezone-data
	)"
RDEPEND="${DEPEND}"

S="${WORKDIR}"

# Adds a "daemon"-type user/group pair.
add_daemon_user() {
       local username="$1"
       local uid="$2"
       enewuser "${username}" "${uid}"
       enewgroup "${username}" "${uid}"
}

pkg_setup() {
	if ! use cros_host ; then
		# The sys-libs/timezone-data package installs a default /etc/localtime
		# file automatically, so scrub that if it's a regular file.
		local etc_tz="${ROOT}etc/localtime"
		[[ -L ${etc_tz} ]] || rm -f "${etc_tz}"
	fi

	# Standard system users/groups. Allow them to get default IDs.
	add_daemon_user "root"
	add_daemon_user "bin"
	add_daemon_user "daemon"
	enewgroup "sys"
	add_daemon_user "adm"
	enewgroup "tty"
	enewgroup "disk"
	add_daemon_user "lp"
	enewuser "sync"
	enewgroup "mem"
	enewgroup "kmem"
	enewgroup "wheel"
	enewgroup "floppy"
	add_daemon_user "news"
	add_daemon_user "uucp"
	enewgroup "console"
	enewgroup "audio"
	enewgroup "cdrom"
	enewgroup "tape"
	enewgroup "video"
	enewgroup "cdrw"
	enewgroup "usb"
	enewgroup "users"
	add_daemon_user "portage"
	enewgroup "utmp"
	enewgroup "nogroup"
	add_daemon_user "nobody"
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

		# Ensure /etc/shadow exists in the target with correct perms.
		# http://bugs.gentoo.org/260993
		touch "${D}/etc/shadow" || die
		chmod 0600 "${D}/etc/shadow" || die

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
	# The user that all user-facing processes will run as.
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

	remove_shadow "${system_user}"
	add_shadow "${system_user}" "${crypted_password}"

	enewgroup "${system_user}" "${system_id}"
	add_daemon_user "${system_user}"
	add_daemon_user "${system_access_user}" "${system_access_id}"

	# The following users and groups should mostly be created by
	# ebuilds that actually need them: http://crbug.com/360815

#	add_daemon_user "messagebus" 201     # For dbus. Now in sys-apps/dbus.
#	add_daemon_user "syslog" 202         # For rsyslog. Now installed by chromeos-init
	add_daemon_user "ntp" 203
#	add_daemon_user "sshd" 204           # For sshd. Now in net-misc/openssh.
	add_daemon_user "polkituser" 206     # For policykit
#	add_daemon_user "tss" 207            # For trousers (TSS/TPM). Now in app-crypt/trousers.
	add_daemon_user "pkcs11" 208         # For pkcs11 clients
#	add_daemon_user "qdlservice" 209     # For QDLService. Now in platform2.
#	add_daemon_user "cromo" 210          # For cromo (modem manager). Now in platform2.
#	add_daemon_user "cashew" 211         # Deprecated, do not reuse
	add_daemon_user "ipsec" 212          # For strongswan/ipsec VPN
#	add_daemon_user "cros-disks" 213     # For cros-disks. Now in platform2.
	add_daemon_user "tor" 214            # For tor (anonymity service)
	add_daemon_user "tcpdump" 215        # For tcpdump --with-user
	add_daemon_user "debugd" 216         # For debugd
	add_daemon_user "openvpn" 217        # For openvpn
	add_daemon_user "bluetooth" 218      # For bluez
	add_daemon_user "wpa" 219            # For wpa_supplicant
	add_daemon_user "cras" 220           # For cras (audio)
#	add_daemon_user "gavd" 221           # For gavd (audio) (deprecated)
	add_daemon_user "input" 222          # For /dev/input/event access
	add_daemon_user "chaps" 223          # For chaps (pkcs11)
	add_daemon_user "dhcp" 224           # For dhcpcd (DHCP client)
	add_daemon_user "tpmd" 225           # For tpmd
#	add_daemon_user "mtp" 226            # For mtpd. In mtpd.
	add_daemon_user "proxystate" 227     # For proxy monitoring
#	add_daemon_user "power" 228          # For powerd. In platform2.
	add_daemon_user "watchdog" 229       # For daisydog
	add_daemon_user "devbroker" 230      # For permission_broker
#	add_daemon_user "xorg" 231           # For Xorg. In xorg-conf
	add_daemon_user "nfqueue" 232        # For netfilter-queue
	add_daemon_user "tlsdate-dbus" 233   # For tlsdate-dbus-announce
	add_daemon_user "tlsdate" 234
	add_daemon_user "debugd-logs" 235    # For debugd's unprivileged logs
	add_daemon_user "debugfs-access" 236 # Access to debugfs
	add_daemon_user "shill-crypto" 237   # For shill's crypto-util
#	add_daemon_user "avahi" 238          # For avahi-daemon
#	add_daemon_user "p2p" 239            # For p2p
	add_daemon_user "brltty" 240         # For braille displays
#	add_daemon_user "modem" 241          # For modem manager. Now in net-misc/modemmanager-next.
	# Reserve some UIDs/GIDs between 300 and 349 for sandboxing FUSE-based
	# filesystem daemons.
#	add_daemon_user "ntfs-3g" 300        # For ntfs-3g prcoess. Now in sys-fs/ntfs-3g.
#	add_daemon_user "avfs" 301           # For avfs process. Now in platform2.
#	add_daemon_user "fuse-exfat" 302     # For exfat-fuse prcoess. Now in platform2.

	# Group that is allowed to create directories under /home/root/<hash>.
	enewgroup "daemon-store" 400
	enewgroup "logs-access" 401
	enewgroup "serial" 402        # For owning access to serial devices.

	# Create a group for device access via permission_broker.
	enewgroup "devbroker-access" 403
	enewgroup "i2c" 404           # For I2C device node access.

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
