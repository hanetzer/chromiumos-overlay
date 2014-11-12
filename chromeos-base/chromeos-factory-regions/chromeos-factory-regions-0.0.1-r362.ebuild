# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="423a39c7b0acad7678a70257ec134d63ffc65c81"
CROS_WORKON_TREE="acde87469c683cd925ba7a9db09b85631cc84072"
CROS_WORKON_PROJECT="chromiumos/platform/factory"
CROS_WORKON_LOCALNAME="factory"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon

DESCRIPTION="ChromeOS Regions"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

DEPEND="chromeos-base/chromeos-factory"

src_compile() {
	# Disable default compile, since that would call "make"
	# in the factory source tree.
	true
}

src_install() {
	local target_dir="${D}/usr/local/factory/share"
	mkdir -p "${target_dir}"

	# Run regions.py from the SYSROOT, since only there will it have
	# the complete list of regions including those from the
	# overlay.
	local regions_py="${SYSROOT}/usr/local/factory/py/l10n/regions.py"
	export PYTHONDONTWRITEBYTECODE=1
	# Generate list of confirmed regions.
	"${regions_py}" --format yaml > "${target_dir}/regions.yaml" || die
	# Generate list of all regions, including unconfimed ones.
	"${regions_py}" --format yaml --all > "${target_dir}/regions_all.yaml" \
		|| die
}
