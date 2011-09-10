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
BOARD_USE_PREFIX="board_use_"
ALL_BOARDS=(
    amd64-generic
    amd64-host
    arm-generic
    lumpy
    stumpy
    tegra2
    tegra2_aebl
    tegra2_arthur
    tegra2_asymptote
    tegra2_dev-board
    tegra2_dev-board-opengl
    tegra2_kaen
    tegra2_seaboard
    tegra2_wario
    x86-agz
    x86-alex
    x86-alex_he
    x86-dogfood
    x86-fruitloop
    x86-generic
    x86-mario
    x86-mario64
    x86-pineview
    x86-zgb
    x86-zgb_he
)

# Add BOARD_USE_PREFIX to each board in ALL_BOARDS to create the IUSE list.
IUSE=${ALL_BOARDS[@]/#/${BOARD_USE_PREFIX}}

cros_set_board_environment_variable()
{
    local b

    export BOARD=""
    for b in "${ALL_BOARDS[@]}"; do
        if use ${BOARD_USE_PREFIX}${b}; then
            export BOARD=${b} && return
        fi
    done

    die "Value for BOARD environment variable cannot be determined."
}
