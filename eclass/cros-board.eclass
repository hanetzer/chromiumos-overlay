# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

#
# Original Author: The Chromium OS Authors <chromium-os-dev@chromium.org>
# Purpose: Library for handling building of ChromiumOS packages
#
#
#  This class sets the BOARD environment variable.  It is intended to
#  be used by ebuild packages that need to have the board information
#  for various reasons -- for example, to differentiate various
#  hardware attributes at build time; see 'adhd' for an example of
#  this.
#
#  When set, the BOARD environment variable should conform to the
#  syntax used by the CROS utilities.
#
#  If an unknown board is encountered, this class deliberately fails
#  the build; this provides an easy method of identifying a change to
#  the build which might affect inheriting packages.
#
#  For example, the ADHD (Google A/V daemon) package relies on the
#  BOARD variable to determine which hardware should be monitored at
#  runtime.  If the BOARD variable is not set, the daemon will not
#  monitor any specific hardware; thus, when a new board is added, the
#  ADHD project must be updated.
#
#  BOARD is only set when there is a physical board associated with
#  the current build.  Generic build types, such as 'x86-generic', do
#  not set BOARD.
#
IUSE="alex lumpy mario stumpy tegra2_aebl tegra2_asymptote tegra2_kaen tegra2_seaboard zgb"

cros_set_board_environment_variable()
{
    # Please keep this list sorted.
    local boards=(
        # "<use-flag-name> ${BOARD}"
        "alex x86-alex"
        "lumpy lumpy"
        "mario x86-mario"
        "stumpy stumpy"
        "tegra2_aebl tegra2_aebl"
        "tegra2_asymptote tegra2_asymptote"
        "tegra2_kaen tegra2_kaen"
        "tegra2_seaboard tegra2_seaboard"
        "zgb x86-zgb"
    )
    local b

    export BOARD=""
    for b in "${boards[@]}" ; do
        set -- ${b}             # Set ${1} and ${2}.
        use ${1} && export BOARD=${2} && return
    done
    ewarn "BOARD value cannot be determined; leaving unset."
}
