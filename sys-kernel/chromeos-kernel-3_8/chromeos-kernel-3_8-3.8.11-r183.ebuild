# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="ff1e5f40bc4f1e29ff6bcca65b86aee8b8cb184a"
CROS_WORKON_TREE="bd3ef59e3fa65b7ccf913f9bde8c8d06d9e9bcf8"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel"
CROS_WORKON_LOCALNAME="kernel/v3.8"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon cros-kernel2

DESCRIPTION="Chrome OS Linux Kernel 3.8"
KEYWORDS="*"
