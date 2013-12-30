# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
inherit eutils

DESCRIPTION="The Korean Hangul input engine for IME extension API."
HOMEPAGE="https://code.google.com/p/google-input-tools/"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${PF}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"

src_prepare() {
  epatch "${FILESDIR}"/${P}-insert-public-key.patch
  # Removes unused NaCl binaries.
  if ! use arm ; then
          rm hangul_arm.nexe || die
  fi
  if ! use x86 ; then
          rm hangul_x86_32.nexe || die
  fi
  if ! use amd64 ; then
          rm hangul_x86_64.nexe || die
  fi
}

src_install() {
  insinto /usr/share/chromeos-assets/input_methods/hangul
  doins -r *
}
