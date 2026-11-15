# khinse-labs/.github

Default community health files and templates for every khinse-labs repository.

GitHub uses a file from here for any repository in the organisation that does not have its own file of that type. A repository's own file always wins.

| File | Purpose |
| --- | --- |
| [`.github/ISSUE_TEMPLATE/`](.github/ISSUE_TEMPLATE/) | Issue forms: bug, feature and task. Blank issues are off. |
| [`.github/VULNERABILITY_REPORT.yml`](.github/VULNERABILITY_REPORT.yml) | Form for private vulnerability reports |
| [`.github/pull_request_template.md`](.github/pull_request_template.md) | Pull request template |
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | How to contribute |
| [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md) | Contributor Covenant 2.1 |
| [`SECURITY.md`](SECURITY.md) | How to report a vulnerability privately |
| [`SUPPORT.md`](SUPPORT.md) | Where to get help |
| [`GOVERNANCE.md`](GOVERNANCE.md) | How decisions are made |
| [`profile/README.md`](profile/README.md) | The organisation's public landing page |
| [`.github/workflows/release.yml`](.github/workflows/release.yml) | Reusable release workflow, described [below](#reusable-release-workflow) |
| [`cliff.toml`](cliff.toml) | Shared git-cliff config: release notes and the next version, read by the release workflow |

## Notes for maintainers

- If a repository has its own `.github/ISSUE_TEMPLATE/` folder, none of these issue forms are used there.
- The issue forms set the org issue types Bug, Feature and Task. They apply no labels and add issues to no project: each product's own project adds its repository's issues with its auto-add workflow.
- Licences cannot be set here; add a `LICENSE` to each repository.
- Organisation settings (new repositories, labels, projects) are documented for maintainers in the organisation's internal docs.
- This repository must stay public for the defaults to apply.

See GitHub's guide to [default community health files](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/creating-a-default-community-health-file).

## Reusable release workflow

[`release.yml`](.github/workflows/release.yml) cuts a release for any repository in the organisation. It picks the next version from the Conventional Commits since the last tag, with git-cliff and the shared [`cliff.toml`](cliff.toml). It creates the tag at the triggering commit and publishes a GitHub release with the notes, in one call. If `bump` is `auto` and every unreleased commit is tooling or process (`chore`, `ci`, `build`, `style`, `test`), it releases nothing. `released` is then `false`. It never skips a breaking commit.

### Caller

A repository's release workflow is a caller of about ten lines, plus whatever it does with the new tag:

```yaml
name: Release

on:
  workflow_dispatch:
    inputs:
      bump:
        description: Version bump. auto picks it from the commits.
        type: choice
        options: [auto, patch, minor, major]
        default: auto

permissions:
  contents: read

jobs:
  release:
    permissions:
      contents: write # the called workflow tags and publishes. It can never hold more than this job
    # Pin the latest tag of khinse-labs/.github.
    uses: khinse-labs/.github/.github/workflows/release.yml@v0.1.0
    with:
      bump: ${{ inputs.bump }}
      # include-paths: apps/app/** packages/**

  deploy:
    needs: release
    if: needs.release.outputs.released == 'true'
    runs-on: ubuntu-24.04
    permissions:
      contents: read
    steps:
      - uses: actions/checkout@<full commit SHA> # vX.Y.Z of actions/checkout
        with:
          ref: refs/tags/${{ needs.release.outputs.tag }}
          persist-credentials: false
      # ... deploy what was just tagged
```

### Inputs and outputs

| Input | Default | Meaning |
| --- | --- | --- |
| `bump` | `auto` | `auto` picks the bump from the commits. `patch`, `minor` or `major` forces it, and releases even when every unreleased commit is tooling or process. |
| `include-paths` | empty | Globs, separated by spaces or newlines, passed to git-cliff as `--include-path`. Only commits that touch these paths count for the version and the notes (for example `apps/app/** packages/**`). Empty counts every commit. |
| `cliff-ref` | `v0.1.0` | Tag of this repository to read `cliff.toml` from. The caller pins the workflow itself by tag, so the default changes only with a new workflow tag. Set it to read another tag. |

| Output | Meaning |
| --- | --- |
| `released` | `true` when the workflow made a release, `false` when there was nothing to release. |
| `tag` | The new tag, such as `v1.2.3`. Empty if the workflow made no release. |
| `version` | The new version without the `v`, such as `1.2.3`. Empty if the workflow made no release. |

### Notes

- **Pin the caller to a tag, such as `@v0.1.0`.** Callers pin the shared config to tags of this repository (`cchk.toml`, `lefthook/conventions.yml`, `cliff.toml`), and the workflow follows the same rule. `v0.1.0` is the first tag of this workflow. The maintainers create it right after the workflow merges.
- **Keep the default of `cliff-ref` on a tag that exists.** If a change to `cliff.toml` alters versions or notes, merge it and make the tag. Then raise the default in a new PR and make a new tag. A change to comments only needs no new default.
- **The calling job needs `contents: write`.** A called workflow can only use the permissions its caller gives it. Keep `permissions: contents: read` for the rest of the caller.
- **A release made with `GITHUB_TOKEN` starts no other workflow.** Workflows on `release` or on a pushed tag do not run. So deploy in a job of the caller. That job has `needs:` for the release job and reads `tag` (see the example). Do not deploy in a separate workflow on the tag.
- **Releases are cut from the default branch only.** The workflow fails on any other ref before it checks anything out, and on a tag-triggered caller.
- **One release at a time.** The called job has `concurrency: group: release` without cancelling. Do not use the group `release` in the caller: the same group in both deadlocks.
- **A tag ruleset can block it.** If the repository restricts who creates `v*` tags, `github-actions` needs a bypass, because the workflow creates the tag with `GITHUB_TOKEN`.
- **One call makes the tag and the release.** A cancelled or timed-out run cannot leave a tag with no release. The tag is lightweight, not annotated.
- [uv](https://docs.astral.sh/uv/) installs git-cliff from PyPI. The workflow pins the third-party actions by commit SHA, and uv and git-cliff by exact version. PyPI does not let an owner replace the files of a version. The workflow does not check hashes of the git-cliff files.

## Licence

The files in this repository are dedicated to the public domain under [CC0 1.0](LICENSE). Copy and adapt them freely. The exception is [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md), which is adapted from the Contributor Covenant and stays under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

This licence covers this repository only. It does not apply to other khinse-labs repositories.
