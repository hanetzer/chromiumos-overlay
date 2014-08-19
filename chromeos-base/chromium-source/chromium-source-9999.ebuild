# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# Downloads Chrome sources to ${CHROMIUM_SOURCE_DIR} which is typically
# set to /var/cache/chromeos-cache/distfiles/target/chrome-src.

EAPI="4"
inherit chromium-source

DESCRIPTION="Source code for the open-source version of Google Chrome web browser"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google
	chrome_internal? ( Google-TOS )"
SLOT="0"
KEYWORDS="~*"
IUSE="
	chrome_internal
	"

src_unpack() {
	chromium-source_src_unpack

	local WHOAMI=$(whoami)
	export EGCLIENT="${EGCLIENT:-/home/${WHOAMI}/depot_tools/gclient}"
	export DEPOT_TOOLS_UPDATE=0

	mkdir -p "${S}"

	if [[ "${CHROMIUM_SOURCE_ORIGIN}" != SERVER_SOURCE ]]; then
		ewarn "Only CHROMIUM_SOURCE_ORIGIN=SERVER_SOURCE makes sense"
		ewarn "with this ebuild. Gracefully exiting."
		return
	fi

	# Portage version without optional portage suffix.
	CHROMIUM_VERSION="${PV/_*/}"

	# Ensure we can write to ${CHROMIUM_SOURCE_DIR} - this variable
	# is set in chromium-source.eclass.
	addwrite "${CHROMIUM_SOURCE_DIR}"

	elog "Checking out CHROMIUM_VERSION = ${CHROMIUM_VERSION}"

	local cmd=( "${CROS_WORKON_SRCROOT}"/chromite/bin/sync_chrome )
	use chrome_internal && cmd+=( --internal )
	if [[ -n "${CROS_SVN_COMMIT}" ]]; then
		cmd+=( --revision="${CROS_SVN_COMMIT}" )
	elif [[ "${CHROMIUM_VERSION}" != "9999" ]]; then
		cmd+=( --tag="${CHROMIUM_VERSION}" )
	fi
	# --reset tells sync_chrome to blow away local changes and to feel
	# free to delete any directories that get in the way of syncing. This
	# is needed for unattended operation.
	cmd+=( --reset --gclient="${EGCLIENT}" "${CHROMIUM_SOURCE_DIR}" )
	elog "Running: ${cmd[*]}"
	"${cmd[@]}" || die
}
