# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: arc-camera.eclass
# @BLURB: helper eclass for generating camera rules to use cameras under ARC.
# @DESCRIPTION:
# We want to generate camera rules automatically instead of adding the rules for
# every board manually.

inherit udev

# @FUNCTION: arc-camera_gen_and_install_rules
# @DESCRIPTION:
# Read camera_characteristics.conf. Then, generate 50-camera.rules based on
# camera id, vendor id as well as product id, and install the rules.
arc-camera_gen_and_install_rules() {
	local config_file="${D}/etc/camera/camera_characteristics.conf"
	local rules_file="${T}/50-camera.rules"

	if [[ ! -f "${config_file}" ]]; then
		die "camera_characteristics.conf doesn't exist"
	fi

	cat <<-EOF > "${rules_file}"
# Add a symbolic link for internal camera so the container can exclude external
# camera if needed.
EOF
	local line
	while read -r line; do
		if [[ ${line} == *'usb_vid_pid'* ]]; then
			# ${line} format: camera0.module0.usb_vid_pid=0a1b:2c3d
			local camera="${line%%.*}"
			local symlink="${camera/camera/camera-internal}"
			local vid_pid="${line#*=}"
			echo "ATTRS{idVendor}==\"${vid_pid:0:4}\", \
ATTRS{idProduct}==\"${vid_pid:5:4}\", SYMLINK+=\"${symlink}\"" \
			>> "${rules_file}"
		fi
	done < "${config_file}"

	udev_dorules ${rules_file}
}
