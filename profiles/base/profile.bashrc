# Copyright 2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/profiles/base/profile.bashrc,v 1.3 2009/07/21 00:08:05 zmedico Exp $

if ! declare -F elog >/dev/null ; then
	elog() {
		einfo "$@"
	}
fi

cros_stack_bashrc() {
	local cfg cfgd

	cfgd="/usr/local/portage/chromiumos/chromeos/config/env"
	for cfg in ${PN} ${PN}-${PV} ${PN}-${PV}-${PR} ; do
		cfg="${cfgd}/${CATEGORY}/${cfg}"
		[[ -f ${cfg} ]] && . "${cfg}"
	done
}
cros_stack_bashrc

# Packages that use python will run a small python script to find the
# pythondir. Unfortunately, they query the host python to find out the
# paths for things, which means they inevitably guess wrong.  Export
# the cached values ourselves and since we know these are going through
# autoconf, we can leverage ${libdir} that econf sets up automatically.
cros_python_multilib() {
	# Avoid executing multiple times in a single build.
	[[ ${am_cv_python_version:+set} == "set" ]] && return

	local py=${PYTHON:-python}
	local py_ver=$(${py} -c 'import sys;sys.stdout.write(sys.version[:3])')

	export am_cv_python_version=${py_ver}
	export am_cv_python_pythondir="\${libdir}/python${py_ver}/site-packages"
	export am_cv_python_pyexecdir=${am_cv_python_pythondir}
}
cros_python_multilib

# Set LANG=C globally because it speeds up build times, and we don't need
# localized messages inside of our builds.
export LANG=C
