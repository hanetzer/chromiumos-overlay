# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="1cae68fba83a4ff5ea84f4938a89c6eeebdcd364"
CROS_WORKON_TREE="b074803ebac84d993124bfcfbefa68f934adcd40"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_USE_VCSID=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"

PLATFORM_SUBDIR="app_shell_launcher"

inherit cros-workon platform

DESCRIPTION="Launcher for the app_shell binary"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
RDEPEND="chromeos-base/chromeos-chrome[app_shell]"

src_install() {
	# If the first argument is non-empty, echo it to the path contained in the
	# second argument.
	echo_to_file() {
		[ -n "$1" ] && (echo "$1" >"$2")
	}

	# Install data configured via environment variables. The app_shell_launcher
	# Upstart job copies these files to the stateful partition so they can be
	# modified later.
	local data_dir="${WORKDIR}/app_shell"
	mkdir -p "${data_dir}"
	echo_to_file "${APP_ID}" "${data_dir}/app_id"
	echo_to_file "${PREFERRED_NETWORK}" "${data_dir}/preferred_network"

	if [ -n "${APP_PATH}" ]; then
		[ -n "${APP_ID}" ] && die "Both APP_ID and APP_PATH are set"
		local manifest_file="${APP_PATH}/manifest.json"
		[ -f "${manifest_file}" ] || die "${manifest_file} doesn't exist"
		mkdir -p "${data_dir}/app"
		cp -r "${APP_PATH}"/* "${data_dir}/app"
	fi

	insinto /usr/share
	doins -r "${data_dir}"

	dobin "${OUT}/app_shell_launcher"
	insinto /etc/init
	doins init/*.conf
}
