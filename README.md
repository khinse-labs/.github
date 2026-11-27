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
| [`vale/khinse-labs/`](vale/khinse-labs/) | Shared Vale package: the prose rules and their base config, described [below](#shared-vale-config) |
| [`.github/workflows/vale-package.yml`](.github/workflows/vale-package.yml) | Builds `khinse-labs.zip` from `vale/khinse-labs/` and attaches it to a release |
| [`.github/workflows/vale.yml`](.github/workflows/vale.yml) | Reusable Vale check for pull requests, described [below](#shared-vale-config) |

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

## Shared Vale config

[`vale/khinse-labs/`](vale/khinse-labs/) is a [Vale package](https://docs.vale.sh/keys/packages) with the prose rules for every repository in the organisation. It holds four styles: `khinse-labs` (the house rules), `SE` (Simplified English), `write-good` and the views in `config`. Its [`.vale.ini`](vale/khinse-labs/.vale.ini) turns on `khinse-labs`, `SE`, `write-good` and Vale's own style for every file, and sets the rule levels. [`vale-package.yml`](.github/workflows/vale-package.yml) packs the folder as `khinse-labs.zip` and attaches it to each release of this repository.

### Repository config

A repository names the package in the `.vale.ini` at its root:

```ini
StylesPath = .vale/styles
Packages = https://github.com/khinse-labs/.github/releases/download/<tag>/khinse-labs.zip
```

`vale sync` downloads the package. It copies the styles into `.vale/styles` and the package config into `.vale/styles/.vale-config/`. Vale reads the package config first and the repository's file last. In the repository's file, `BasedOnStyles` adds styles to the list of the package. Any other key, such as a rule level, replaces the value of the package.

To pin the exact archive, add its SHA-256 digest to the URL: `khinse-labs.zip#sha256:<digest>`. The summary of the `vale-package.yml` run shows the digest, and `vale sync --plain-progress` prints it. Only Vale 3.29.0 or later checks the digest. An older Vale ignores it.

Git-ignore what `vale sync` writes. If the repository has no styles of its own, ignore `.vale/styles/`. Otherwise keep only your own files:

```gitignore
.vale/styles/*
!.vale/styles/Local/
!.vale/styles/config/
.vale/styles/config/*
!.vale/styles/config/vocabularies/
```

A repository adds its own rules and terms after the package, in the same file:

```ini
StylesPath = .vale/styles
Packages = https://github.com/khinse-labs/.github/releases/download/<tag>/khinse-labs.zip
Vocab = Repo

[*]
BasedOnStyles = Local
SE.Semicolon = warning
write-good.Passive = NO
```

- `Local` is a style of the repository, in `.vale/styles/Local/`. The package uses no style of that name, so `vale sync` leaves it alone.
- `Vocab = Repo` reads terms from `.vale/styles/config/vocabularies/Repo/accept.txt`. `khinse-labs.Spelling` accepts them too. Add a term for every repository to [`spelling-accept.txt`](vale/khinse-labs/styles/khinse-labs/spelling-accept.txt) instead.
- A rule level in `[*]` replaces the level of the package. `NO` turns the rule off.
- To lint the prose in `.mts` files, add `[*.mts]` sections with `View = Mts` or `View = Comments`. The comment in the package [`.vale.ini`](vale/khinse-labs/.vale.ini) has an example.

### Caller

A repository's Vale workflow is a short caller:

```yaml
name: Vale

on:
  pull_request:

permissions:
  contents: read

jobs:
  vale:
    permissions:
      contents: read
      checks: write # github-pr-check writes a check run
      pull-requests: read # reviewdog reads the diff of the pull request
    # Pin the latest tag of khinse-labs/.github.
    uses: khinse-labs/.github/.github/workflows/vale.yml@<tag>
    # with:
    #   files: docs
```

The called workflow sets no permissions of its own. Its job gets the permissions of the calling job, so grant what the reporter needs (see `reporter` below). With `reporter: github-pr-review`, grant `pull-requests: write` instead of `read`.

### Inputs

| Input | Default | Meaning |
| --- | --- | --- |
| `files` | `.` | What Vale lints: a file or folder, a JSON list such as `'["docs", "README.md"]'`, or `all`. |
| `vale-version` | `3.28.1` | Vale version to install, without the `v`. A digest pin needs Vale 3.29.0 or later. Vale 3.29.0 came out on 2026-11-26, so under the rule of 7 days for a new release, use it from 2026-12-03. |
| `fail-on-error` | `true` | Fail the job when Vale reports an alert at the level `error`. Warnings never fail it. |
| `reporter` | `github-pr-check` | reviewdog reporter. Every reporter needs `pull-requests: read` for the diff. `github-pr-check` and `github-check` write a check run and need `checks: write`. `github-pr-review` writes review comments with suggested fixes and needs `pull-requests: write`. `github-pr-annotations` writes annotations through the job log and needs no write permission. |
| `filter-mode` | `added` | reviewdog filter mode. `added` reports alerts on added or changed lines only. `diff_context`, `file` and `nofilter` report more. |

### Local use

Install Vale. Then, at the root of the repository:

```sh
vale sync
vale .
```

Run `vale sync` again after you change the `Packages` line.

### Notes

- **On GitHub Free, the check cannot block a merge in a private repository.** Rulesets and branch protection make a check required, and GitHub Free has them for public repositories only. In a private repository the check only reports.
- **Pin the caller and the package to a tag.** A new tag can bring new rules. Raise the tag in the workflow and in `.vale.ini` together.
- **`vale-package.yml` runs when someone publishes a release.** A release made with `GITHUB_TOKEN`, such as one from `release.yml`, starts no other workflow. Then run `vale-package.yml` by hand with the tag. The build gives the same bytes for the same tag, so a second run keeps a pinned digest valid.
- **Keep immutable releases off for this repository.** `vale-package.yml` uploads the zip after the release is out, and GitHub refuses a new asset on an immutable release. To turn them on, attach the zip to the draft before you publish it.
- **A pull request from a fork gets a read-only token.** reviewdog cannot write a check run or a review there. It writes annotations through the job log instead.
- **Do not edit the synced styles.** `vale sync` replaces them. Change the rules here and make a new tag.
- The `write-good` style is an unchanged copy of v0.5.0 (see its [`SOURCE.md`](vale/khinse-labs/styles/write-good/SOURCE.md)). Turn its rules on or off in the package `.vale.ini`, not in the rule files.

## Licence

The files in this repository are dedicated to the public domain under [CC0 1.0](LICENSE). Copy and adapt them freely. The exception is [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md), which is adapted from the Contributor Covenant and stays under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). Two vendored parts of the Vale package keep their MIT licences: the `write-good` style (see its [`LICENSE`](vale/khinse-labs/styles/write-good/LICENSE)) and the TypeScript grammar (see its [`SOURCE.md`](vale/khinse-labs/styles/config/grammars/SOURCE.md)).

This licence covers this repository only. It does not apply to other khinse-labs repositories.
