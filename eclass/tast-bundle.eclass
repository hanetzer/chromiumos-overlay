# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: tast-bundle.eclass
# @MAINTAINER:
# The Chromium OS Authors <chromium-os-dev@chromium.org>
# @BUGREPORTS:
# Please report bugs via https://crbug.com/new (with component "Tests>Tast")
# @VCSURL: https://chromium.googlesource.com/chromiumos/overlays/chromiumos-overlay/+/master/eclass/@ECLASS@
# @BLURB: Eclass for building and installing Tast test bundles.
# @DESCRIPTION:
# Installs Tast integration test bundles.
# See https://chromium.googlesource.com/chromiumos/platform/tast/ for details.
# The bundle name (e.g. "cros") and type ("local" or "remote") are derived from
# the package name, which should be of the form "tast-<type>-tests-<name>".

inherit cros-go

DEPEND="chromeos-base/tast-common"

if ! [[ "${PN}" =~ ^tast-(local|remote)-tests-[a-z]+$ ]]; then
	die "Package \"${PN}\" not of form \"tast-<type>-tests-<name>\""
fi

# @FUNCTION: tast-bundle_pkg_setup
# @DESCRIPTION:
# Parses package name to extract bundle info and sets binary target.
tast-bundle_pkg_setup() {
	# Strip off the "tast-" prefix and the "-tests-*" suffix to get the type
	# ("local" or "remote").
	local tmp=${PN#tast-}
	TAST_BUNDLE_TYPE=${tmp%-tests-*}

	# Strip off everything preceding the bundle name.
	TAST_BUNDLE_NAME=${PN#tast-*-tests-}

	# Install the bundle under /usr/libexec/tast/bundles/<type>.
	CROS_GO_BINARIES=(
		"chromiumos/tast/${TAST_BUNDLE_TYPE}/bundles/${TAST_BUNDLE_NAME}:/usr/libexec/tast/bundles/${TAST_BUNDLE_TYPE}/${TAST_BUNDLE_NAME}"
	)
}

# @FUNCTION: tast-bundle_src_install
# @DESCRIPTION:
# Installs test bundle executable and associated data files.
tast-bundle_src_install() {
	cros-go_src_install

	# Install each test category's data dir (with its full path within the src/
	# directory) under /usr/share/tast/data/<type>.
	pushd src >/dev/null || die "failed to pushd src"
	local bundle="chromiumos/tast/${TAST_BUNDLE_TYPE}/bundles/${TAST_BUNDLE_NAME}"
	local datadir
	for datadir in "${bundle}"/*/data; do
		[[ -e "${datadir}" ]] || break
		(insinto "/usr/share/tast/data/${TAST_BUNDLE_TYPE}/${datadir%/*}" && doins -r "${datadir}")
	done
	popd >/dev/null
}

EXPORT_FUNCTIONS pkg_setup src_install
