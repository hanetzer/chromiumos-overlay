# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: cros-i686.eclass
# @BLURB: eclass for building i686 binaries on x86_64
# @DESCRIPTION:
# Multilib builds are not supported in Chrome OS. A simple workaround for i686
# builds on x86_64 is to use the host toolchain. This eclass provides helper
# functions for i686 environment setup, as well as integration with platform2
# packages. The "cros_i686" USE flag determines whether a package should also
# build i686 binaries on x86_64.

inherit cros-au cros-workon platform

IUSE="cros_i686"

use_i686() { use cros_i686 && use amd64; }

push_i686_env() {
	board_setup_32bit_au_env
	export CC=${CHOST}-gcc
	export CXX=${CHOST}-g++
}

pop_i686_env() {
	export CXX=${__AU_OLD_CXX}
	export CC=${__AU_OLD_CC}
	board_teardown_32bit_au_env
}

_get_i686_cache() {
	echo "$(cros-workon_get_build_dir)/i686"
}

platform_src_configure_i686() {
	local cache=$(_get_i686_cache)
	push_i686_env
	platform_src_configure "--cache_dir=${cache}"
	pop_i686_env
}

platform_src_compile_i686() {
	local cache=$(_get_i686_cache)
	push_i686_env
	platform "compile" "--cache_dir=${cache}" "$@"
	pop_i686_env
}

platform_out_i686() {
	echo "$(_get_i686_cache)/out/Default"
}
