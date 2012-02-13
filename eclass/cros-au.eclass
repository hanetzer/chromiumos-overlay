# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

#
# Original Author: The Chromium OS Authors <chromium-os-dev@chromium.org>
# Purpose: Library for handling packages that are part of Auto Update.
#

inherit flag-o-matic

# Some boards started out 32bit (user/kernel) and then migrated to 64bit
# (user/kernel).  Since we need to auto-update (AU) from the 32bit to
# 64bit, and the old 32bit kernels can't execte 64bit code, we need to
# always build the AU code as 32bit.
#
# Setup the build env to create 32bit objects.
board_setup_32bit_au_env()
{
	: ${ORIG_SYSROOT:=${SYSROOT}}

	export ARCH=x86 ABI=x86 LIBDIR_x86="lib"
	export CHOST=i686-pc-linux-gnu
	export SYSROOT=/usr/${CHOST}
	append-ldflags -L"${ORIG_SYSROOT}"/usr/lib
	append-cxxflags -isystem "${ORIG_SYSROOT}"/usr/include
}
