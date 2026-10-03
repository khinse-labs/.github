#!/bin/sh
# Conventional Branch name for the branch checked out when pushing.
set -eu
here=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
. "$here/../commit-check.sh"
commit_check --branch
