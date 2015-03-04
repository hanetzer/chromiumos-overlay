# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="60fd2b2152054d5d549bcb3adefa3d2be1b62f91"
CROS_WORKON_TREE="d3832f92ef9f9a09092b9d96686d5d4f2ec4cc5b"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_USE_VCSID=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="app_shell_launcher"

inherit cros-workon platform

DESCRIPTION="Launcher for the app_shell binary"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

DEPEND="chromeos-base/libchromeos"
RDEPEND="${DEPEND}
	chromeos-base/chromeos-chrome[app_shell]"

src_install() {
	# If the first argument is non-empty, echo it to the path contained in the
	# second argument.
	echo_to_file() {
		[[ -n "$1" ]] && (echo "$1" >"$2")
	}

	# Install data configured via environment variables. The app_shell_launcher
	# Upstart job copies these files to the stateful partition so they can be
	# modified later.
	#
	# These are just intended for use by developers doing a one-off build with
	# a custom app. Boards that are intended to include specific apps should
	# instead use a BSP to install the apps to /usr/share/app_shell/apps.
	local data_dir="${WORKDIR}/app_shell"
	mkdir -p "${data_dir}"
	echo_to_file "${PREFERRED_NETWORK}" "${data_dir}/preferred_network"

	if [[ -n "${APP_PATH}" ]]; then
		local manifest_file="${APP_PATH}/manifest.json"
		[[ -f "${manifest_file}" ]] || die "${manifest_file} doesn't exist"
		mkdir -p "${data_dir}/apps/app"
		cp -r "${APP_PATH}"/* "${data_dir}/apps/app"
	fi

	insinto /usr/share
	doins -r "${data_dir}"

	dobin "${OUT}/app_shell_launcher"
	insinto /etc/init
	doins init/*.conf

	insinto /etc
	doins app_shell_dev.conf
}
