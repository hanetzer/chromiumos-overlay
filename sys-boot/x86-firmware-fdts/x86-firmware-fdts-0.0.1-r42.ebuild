# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="0304a8882bf70d40abe6ed583f25e9f93b5d0b81"

inherit cros-fdt

CROS_WORKON_PROJECT="chromiumos/third_party/u-boot"
CROS_WORKON_LOCALNAME="u-boot"
CROS_WORKON_SUBDIR="files"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon

DESCRIPTION="X86 variant FDT files"
LICENSE=""
SLOT="0"
KEYWORDS="x86"
IUSE=""

# Build all coreboot files
CROS_FDT_ROOT="board/chromebook-x86/coreboot"
CROS_FDT_SOURCES="*"
