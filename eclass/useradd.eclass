# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
# $Header: $

#
# useradd.eclass
#
# Adds a mechanism for adding users/groups into alternate roots.
#
# This will likely go away.
#
# Authors:
# Google, inc. <chromium-os-dev@chromium.org>
#

HOMEPAGE="http://www.chromium.org/"

# Add entry to /etc/passwd
#
# $1 - Username (e.g. "messagebus")
# $2 - "*" to indicate not shadowed, "x" to indicate shadowed
# $3 - UID (e.g. 200)
# $4 - GID (e.g. 200)
# $5 - full name (e.g. "")
# $6 - home dir (e.g. "/home/foo" or "/var/run/dbus")
# $7 - shell (e.g. "/bin/sh" or "/bin/false")
add_user() {
  echo "${1}:${2}:${3}:${4}:${5}:${6}:${7}" | \
    sudo dd of="${ROOT}/etc/passwd" conv=notrunc oflag=append
}

# Add entry to /etc/shadow
#
# $1 - Username
# $2 - Crypted password
add_shadow() {
  echo "${1}:${2}:14500:0:99999::::" | \
    sudo dd of="${ROOT}/etc/shadow" conv=notrunc oflag=append
}

# Add entry to /etc/group
# $1 - Groupname (e.g. "messagebus")
# $2 - GID (e.g. 200)
add_group() {
  echo "${1}:x:${2}:" | \
    sudo dd of="${ROOT}/etc/group" conv=notrunc oflag=append
}
