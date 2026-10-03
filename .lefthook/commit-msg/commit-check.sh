#!/bin/sh
# Conventional Commits for the message git is about to record.
set -eu
here=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
. "$here/../commit-check.sh"
commit_check --message "${1:?commit-msg hook needs the message file}"
