# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="25a21ab56c14ea728477b2257894ad3c41db1cc1"
CROS_WORKON_TREE="e320c7e75437fe08eb1fd6fa795255564c3a42e9"

EAPI=4
CROS_WORKON_PROJECT="chromiumos/third_party/kernel"

# TODO(jglasgow) Need to fix DEPS file to get rid of "files"
CROS_WORKON_LOCALNAME="../third_party/kernel/files"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon cros-kernel2

DESCRIPTION="Chrome OS Kernel"
KEYWORDS="amd64 arm x86"

DEPEND="!sys-kernel/chromeos-kernel-next"
RDEPEND="!sys-kernel/chromeos-kernel-next"

