#!/bin/sh
exec gawk '{print gensub(/[[\],]/, "", "g", $2); exit}' "$1"/configure.ac
