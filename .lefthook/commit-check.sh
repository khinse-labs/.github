# Sourced by the hook scripts. Runs commit-check through uvx, so the only thing a machine needs
# is uv (https://docs.astral.sh/uv/); uv fetches Python and commit-check on first use.
#
# A repository's own cchk.toml wins: it inherits ours with
#   inherit_from = "github:khinse-labs/.github@<commit-sha>:cchk.toml"
# and can override it. Without one, use the copy lefthook cloned with this script.

COMMIT_CHECK_VERSION=2.18.2

commit_check() {
  if ! command -v uvx >/dev/null 2>&1; then
    echo "commit-check needs uv: https://docs.astral.sh/uv/getting-started/installation/" >&2
    exit 1
  fi
  root=$(git rev-parse --show-toplevel)
  for own in cchk.toml commit-check.toml .github/cchk.toml .github/commit-check.toml; do
    if [ -f "$root/$own" ]; then
      exec uvx --quiet "commit-check@$COMMIT_CHECK_VERSION" --no-banner "$@"
    fi
  done
  exec uvx --quiet "commit-check@$COMMIT_CHECK_VERSION" --no-banner --config "$here/../../cchk.toml" "$@"
}
