# Copyright 2018 The Chromium Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

DESCRIPTION="Chrome OS SELinux Policy Package"
SLOT="0"
KEYWORDS="*"
LICENSE="BSD-Google"
IUSE="cheets_local_img android-container-pi android-container-master-arc-dev"
DEPEND="
	android-container-pi? ( chromeos-base/android-container-pi:0= )
	android-container-master-arc-dev? ( chromeos-base/android-container-master-arc-dev:0= )
"

SELINUX_VERSION="30"
SEPOLICY_FILENAME="policy.${SELINUX_VERSION}"

S="${WORKDIR}"

src_compile() {
	# Files under $SEPATH are built by android-container-* in DEPEND.
	local SEPATH="${SYSROOT}/etc/selinux/intermediates/"
	if use cheets_local_img; then
		# Currently, developers are responsible to put the final policy
		# into files directory of android-container-pi when
		# cheets_local_img use flag is set.
		# Simply copying it here.
		cp "${SEPATH}/sepolicy" "${SEPOLICY_FILENAME}"
	# TODO(fqj): change back to else.
	# This is for master port progress, that we don't need to compile the policy
	# before master container adds the intermediate files.
	elif [[ -f "${SEPATH}/plat_sepolicy.cil" ]]; then
		# -M Build MLS policy.
		# -G expand and remove auto-generated attributes.
		# -N ignore neverallow rules (checked during Android build)
		# -m allow multiple declaration (combination of rules of multiple source)
		secilc "${SEPATH}/plat_sepolicy.cil" -M true -G -N -m -c "${SELINUX_VERSION}" \
			"${SEPATH}/mapping.cil" -o "${SEPOLICY_FILENAME}" \
			"${SEPATH}/plat_pub_versioned.cil" \
			"${SEPATH}/vendor_sepolicy.cil" \
			-f /dev/null || die "fail to build sepolicy"
	fi

	cat "${FILESDIR}/chromeos_file_contexts" \
		"${SYSROOT}/etc/selinux/intermediates/arc_file_contexts" > file_contexts
}

src_install() {
	# TODO(fqj): remove this.
	# Only installs for master container if it's not installed by the
	# container package.
	if use android-container-master-arc-dev; then
		if [[ ! -f "${SYSROOT}/etc/selinux/config" ]]; then
			insinto /etc/selinux/arc/contexts/files/
			doins file_contexts

			insinto /etc/selinux/
			newins "${FILESDIR}"/selinux_config config

			insinto /etc/selinux/arc/policy
			doins "${SEPOLICY_FILENAME}"
		fi
		return;
	fi

	insinto /etc/selinux/arc/contexts/files/
	doins file_contexts

	insinto /etc/selinux/
	newins "${FILESDIR}"/selinux_config config

	insinto /etc/selinux/arc/policy
	doins "${SEPOLICY_FILENAME}"
}

