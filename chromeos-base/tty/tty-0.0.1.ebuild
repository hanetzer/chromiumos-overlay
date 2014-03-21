# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

DESCRIPTION="Init script to run agetty on selected terminals."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

USE_PREFIX="tty_console_"

ALL_PORTS=(
	ttyAMA{0..5}
	ttyO{0..5}
	ttyS{0..5}
	ttySAC{0..5}
	tty{0..5}
)

IUSE_PORTS="${ALL_PORTS[@]/#/${USE_PREFIX}}"
IUSE="${IUSE_PORTS}"

RDEPEND="
	sys-apps/upstart
	tty_console_tty2? ( !<chromeos-base/chromeos-init-0.0.22 )
	tty_console_tty1? ( !chromeos-base/tty1 )
"
RDEPEND+="$(for t in ${IUSE_PORTS}; do
	echo " ${t}? ( !chromeos-base/serial-tty[${t}] )"
	done)"

S="${WORKDIR}"

src_compile() {
	# Generate a file for each activated tty console.
	local item

	for item in ${IUSE_PORTS}; do
		use ${item} && generate_init_script ${item}
	done
}

generate_init_script() {
	# Creates an init script per activated console by copying the base script and
	# changing the port number.
	local port="${1#${USE_PREFIX}}"

	sed -e "s|%PORT%|${port}|g" \
		"${FILESDIR}"/tty-base.conf \
		> console-${port}.conf || die "failed to generate ${port}"
}

src_install() {
	if [[ -n ${TTY_CONSOLE} ]]; then
		insinto /etc/init
		doins console-*.conf
	fi
}
