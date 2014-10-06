#!/bin/bash

# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

source tests-common.sh

inherit osreleased

valid_names=(
	'GOOGLE_METRICS_ID'
	'THIS_IS_A_TEST'
)

invalid_names=(
	'this_is_not_valid'
	'THIS/IS/NOT/VALID/EITHER'
	'NOT THIS EITHER'
	'OR \nTHIS'
	'OR=THIS'
)

invalid_values=(
	'this is
not valid'
)


tbegin "no args"
! (do_osrelease_field) >&/dev/null
tend $?

tbegin "too many args"
! (do_osrelease_field HELLO 1234 test) >&/dev/null
tend $?

tbegin "invalid names"
for input in "${invalid_names[@]}" ; do
	if (do_osrelease_field "${input}" "value") >&/dev/null ; then
		tend 1 "bad input not caught: ${input}"
	fi
	rm -rf "${D}"
done
tend $?

tbegin "invalid values"
for input in "${invalid_values[@]}" ; do
	if (do_osrelease_field "NAME" "${input}") >&/dev/null ; then
		tend 1 "bad input not caught: ${input}"
	fi
	rm -rf "${D}"
done
tend $?

tbegin "valid names"
for input in "${valid_names[@]}" ; do
	if ! (do_osrelease_field "$input" "value") ; then
		tend 1 "valid input blocked: ${input}"
	fi
	rm -rf "${D}"
done
tend $?

texit
