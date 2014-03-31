# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

LICENSE="BSD-Google"
KEYWORDS="*"

pkg_setup() {
	ewarn "This package is dead.  Please stop using it."
	ewarn "Switch to virtual/target-sdk instead."
}
