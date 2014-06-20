# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

inherit cros-board cros-debug

DESCRIPTION="Text file listing USE flags for chromeos-base/libchromeos"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

# NB: Flags listed here are off by default unless prefixed with a '+'.
# This list is lengthy since it determines the USE flags that will be written to
# the /etc/ui_use_flags.txt file that's used to generate Chrome's command line.
IUSE="
	asan
	cros-debug
	deep_memory_profiler
	disable_login_animations
	disable_webaudio
	egl
	fade_boot_splash_screen
	gpu_sandbox_allow_sysv_shm
	gpu_sandbox_start_after_initialization
	has_diamond_key
	has_hdd
	highdpi
	legacy_keyboard
	legacy_power_button
	moblab
	natural_scroll_default
	neon
	ozone
	ozone_platform_dri
	test
	+X
"

S=${WORKDIR}

src_install() {
	# Install a file containing a list of currently-set USE flags that
	# ChromiumCommandBuilder reads at runtime while constructing Chrome's
	# command line.
	local path="${WORKDIR}/ui_use_flags.txt"
	cat <<EOF >"${path}"
# This file is just for libchromeos's ChromiumCommandBuilder class.
# Don't use it for anything else. Your code will break.
EOF

	# If you need to use a new flag, add it to $IUSE at the top of the file.
	local flags=( ${IUSE} )
	local flag
	for flag in ${flags[@]/#[-+]} ; do
		usev ${flag}
	done | sort -u >>"${path}"

	insinto /etc
	doins "${path}"
}
