# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="c586d4b1e4ebeaa0122b32837c61577b57c8c1bc"
CROS_WORKON_TREE="2fd1a36d85b34f2abdd78a7b8fe5e5db83b30e29"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel"
CROS_WORKON_LOCALNAME="kernel/v3.8"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon cros-kernel2

DESCRIPTION="Chrome OS Linux Kernel 3.8"
KEYWORDS="*"
