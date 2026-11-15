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

[`release.yml`](.github/workflows/release.yml) cuts a release for any repository in the organisation. It picks the next version from the Conventional Commits since the last tag (git-cliff, with the shared [`cliff.toml`](cliff.toml)), creates an annotated tag at the triggering commit, and publishes a GitHub release with the notes. When every unreleased commit is tooling or process (`chore`, `ci`, `build`, `style`, `test`) and `bump` is `auto`, it releases nothing and says so: `released` is `false`. A breaking commit is never skipped.

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
      contents: write # the called workflow tags and publishes; it can never hold more than this job
    # PLACEHOLDER: vX.Y.Z is not a real tag. Use the latest tag of khinse-labs/.github.
    uses: khinse-labs/.github/.github/workflows/release.yml@vX.Y.Z
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
| `bump` | `auto` | `auto` picks the bump from the commits; `patch`, `minor` or `major` forces it, and releases even when every unreleased commit is tooling or process. |
| `include-paths` | empty | Globs, separated by spaces or newlines, passed to git-cliff as `--include-path`. Only commits that touch these paths count for the version and the notes (for example `apps/app/** packages/**`). Empty counts every commit. |
| `cliff-ref` | the latest tag that had `cliff.toml` when the workflow was tagged | Tag of this repository to read `cliff.toml` from. The caller pins the workflow itself by tag, so the default only changes with it. Set it to read another tag. |

| Output | Meaning |
| --- | --- |
| `released` | `true` when a release was made, `false` when there was nothing to release. |
| `tag` | The new tag, such as `v1.2.3`. Empty when nothing was released. |
| `version` | The new version without the `v`, such as `1.2.3`. Empty when nothing was released. |

### Notes

- **Pin the caller to a tag, `@vX.Y.Z`.** The shared config is pinned to tags of this repository (`cchk.toml`, `lefthook/conventions.yml`, `cliff.toml`), and the workflow follows the same rule. The tag is made by the maintainers after the change merges, so the examples use `vX.Y.Z` as a placeholder: replace it with a real tag. Before tagging, move the default of `cliff-ref` to the tag you are about to make if `cliff.toml` changed.
- **The calling job needs `contents: write`.** A called workflow can only use the permissions its caller gives it. Keep `permissions: contents: read` for the rest of the caller.
- **A release made with `GITHUB_TOKEN` starts no other workflow.** Workflows on `release` or on a pushed tag do not run, so deploy as a job of the caller that `needs:` the release job and reads `tag` (see the example), not as a separate workflow on the tag.
- **Releases are cut from the default branch only.** The workflow fails on any other ref before it checks anything out, and on a tag-triggered caller.
- **One release at a time.** The called job has `concurrency: group: release` without cancelling. Do not use the group `release` in the caller: the same group in both deadlocks.
- **A tag ruleset can block it.** If the repository restricts who creates `v*` tags, `github-actions` needs a bypass, because the workflow pushes the tag with `GITHUB_TOKEN`.
- **A failed release leaves no tag.** If publishing fails after the tag was pushed, the workflow deletes the tag, so a rerun gets the same version.
- git-cliff is installed from PyPI through [uv](https://docs.astral.sh/uv/), both pinned: the third-party actions by commit SHA and git-cliff by exact version.

## Licence

The files in this repository are dedicated to the public domain under [CC0 1.0](LICENSE). Copy and adapt them freely. The exception is [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md), which is adapted from the Contributor Covenant and stays under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

This licence covers this repository only. It does not apply to other khinse-labs repositories.
