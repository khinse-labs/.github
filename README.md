# khinse-labs/.github

<!-- vale ai-tells.NounString = NO -->

Default community health files and templates for every khinse-labs repository.

<!-- vale ai-tells.NounString = YES -->

GitHub uses a file from here for any repository in the organisation that does not have its own file of that type. A repository's own file always takes priority.

| File | Purpose |
| --- | --- |
| [`.github/ISSUE_TEMPLATE/`](.github/ISSUE_TEMPLATE/) | Issue forms: bug, feature and task. Blank issues are off. |
| [`.github/VULNERABILITY_REPORT.yml`](.github/VULNERABILITY_REPORT.yml) | Form for private vulnerability reports |
| [`.github/pull_request_template.md`](.github/pull_request_template.md) | Pull request template |
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | How to contribute |
| [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md) | Contributor Covenant 2.1 |
| [`SECURITY.md`](SECURITY.md) | How to report a vulnerability privately |
| [`SUPPORT.md`](SUPPORT.md) | Where to get help |
| [`GOVERNANCE.md`](GOVERNANCE.md) | How the organisation decides |
| [`profile/README.md`](profile/README.md) | The organisation's public landing page |
| [`.github/workflows/release.yml`](.github/workflows/release.yml) | Reusable release workflow, described [below](#reusable-release-workflow) |
| [`cliff.toml`](cliff.toml) | Shared git-cliff config: release notes and the next version, read by the release workflow |
| [`vale/khinse-labs/`](vale/khinse-labs/) | Shared Vale package: the prose rules and their base config, described [below](#shared-vale-config) |
| [`.github/workflows/vale-package.yml`](.github/workflows/vale-package.yml) | Tests the Vale rules, builds `khinse-labs.zip` from `vale/khinse-labs/` and attaches it to a release |

## Notes for maintainers

- If a repository has its own `.github/ISSUE_TEMPLATE/` folder, GitHub uses none of these issue forms there.
- The issue forms set the org issue types Bug, Feature and Task. They do not apply labels or add issues to a project: each product's own project adds its repository's issues with its auto-add workflow.
- This repository cannot set a default licence. Add a `LICENSE` to each repository.
- The organisation's internal docs describe the organisation settings (new repositories, labels, projects) for maintainers.
- This repository must be public for the defaults to apply.

See GitHub's guide to [default community health files](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/creating-a-default-community-health-file).

## Reusable release workflow

[`release.yml`](.github/workflows/release.yml) cuts a release for any repository in the organisation. It picks the next version from the Conventional Commits since the last tag, with git-cliff and the shared [`cliff.toml`](cliff.toml). It creates the tag at the triggering commit and publishes a GitHub release with the notes, in one call. If `bump` is `auto` and every unreleased commit is tooling or process (`chore`, `ci`, `build`, `style`, `test`), it releases nothing. `released` is then `false`. It never skips a breaking commit.

### Caller

The release workflow of a repository is a caller of about ten lines, plus whatever it does with the new tag:

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
| `cliff-ref` | `v0.1.0` | Tag of this repository to read `cliff.toml` from. The caller pins the workflow itself by tag. The default then changes only with a new workflow tag. Set it to read another tag. |

| Output | Meaning |
| --- | --- |
| `released` | `true` when the workflow made a release, `false` when there was nothing to release. |
| `tag` | The new tag, such as `v1.2.3`. Empty if the workflow did not release. |
| `version` | The new version without the `v`, such as `1.2.3`. Empty if the workflow did not release. |

### Notes

- **Pin the caller to a tag, such as `@v0.1.0`.** Callers pin the shared config to tags of this repository (`cchk.toml`, `lefthook/conventions.yml`, `cliff.toml`), and the workflow follows the same rule. `v0.1.0` is the first tag of this workflow. The maintainers create it right after the workflow merges.
- **Keep the default of `cliff-ref` on a tag that exists.** If a change to `cliff.toml` alters versions or notes, merge it and make the tag. Then raise the default in a new PR and make a new tag. A change to comments only does not need a new default.
- **The calling job needs `contents: write`.** A called workflow can only use the permissions its caller gives it. Keep `permissions: contents: read` for the rest of the caller.
- **A release made with `GITHUB_TOKEN` does not start other workflows.** Workflows on `release` or on a pushed tag do not run. So deploy in a job of the caller. That job has `needs:` for the release job and reads `tag` (see the example). Do not deploy in a separate workflow on the tag.
- **Only the default branch can release.** The workflow fails on any other ref before it checks anything out, and on a tag-triggered caller.
- **One release at a time.** The called job has `concurrency: group: release` without cancelling. Do not use the group `release` in the caller: the same group in both deadlocks.
- **A tag ruleset can block it.** If the repository restricts who creates `v*` tags, `github-actions` needs a bypass, because the workflow creates the tag with `GITHUB_TOKEN`.
- **One call makes the tag and the release.** A cancelled or timed-out run cannot leave a tag with no release. The tag is lightweight, not annotated.
- [uv](https://docs.astral.sh/uv/) installs git-cliff from PyPI. The workflow pins the third-party actions by commit SHA, and uv and git-cliff by exact version. PyPI does not let an owner replace the files of a version. The workflow does not check hashes of the git-cliff files.

## Shared Vale config

[`vale/khinse-labs/`](vale/khinse-labs/) is a [Vale package](https://docs.vale.sh/keys/packages) with the prose rules for every repository in the organisation. It contains two styles of its own, `khinse-labs` (the house rules) and `SE` (Simplified English), and the views in `config`. Its [`.vale.ini`](vale/khinse-labs/.vale.ini) names more packages from the [Vale package library](https://vale.sh/explorer), and `vale sync` installs them too:

| Package | What it adds |
| --- | --- |
| `write-good` | Passive voice, wordy phrases and repeated words |
| `Readability` | The Flesch-Kincaid grade of each paragraph of 25 words or more, as a warning above 12 |
| `TechTerms` | A dictionary of technical terms for `khinse-labs.Spelling` |
| `Prompts` | Checks for `AGENTS.md`, `CLAUDE.md` and `SKILL.md` files |
| `Modelese` | Phrases that language models overuse |
| `ai-tells` | More patterns of generated prose, as warnings |
| `alex` | Words that are not inclusive |

The `.vale.ini` turns the styles and Vale's own style on for every file. `Prompts` is on only for `AGENTS.md`, `CLAUDE.md` and `SKILL.md` files, and `TechTerms` only adds a spelling dictionary. The `.vale.ini` also sets the rule levels, and it turns off the `ai-tells` rules that repeat a rule of `khinse-labs` or `SE`. It pins each package to a release and to the SHA-256 of its archive. [`vale-package.yml`](.github/workflows/vale-package.yml) runs the tests of the rules, then packs the folder as `khinse-labs.zip` and attaches it to each release of this repository.

Vale lints the prose of more than Markdown:

- **YAML and TOML files.** The `Prose` view in `config/views` picks their comments and the string values of some keys, at any depth. The keys are `name`, `description`, `title`, `summary`, `label`, `placeholder`, `message` and `about`. It also picks the items of an `options` list. Examples are manifests, issue forms and workflow inputs. Other keys, ids and `run:` scripts are not linted.
- **Front matter.** Vale lints each top-level string value of the YAML front matter of a Markdown file by default, such as the `description` of a `SKILL.md`. It does not lint nested values or lists there.

### Repository config

A repository adds the package to the `.vale.ini` at its root:

```ini
StylesPath = .vale/styles
Packages = https://github.com/khinse-labs/.github/releases/download/<tag>/khinse-labs.zip
Grammars = yaml, toml
```

The package names the same grammars, but the first `vale sync` installs only the grammars in the repository's file. Without them, Vale finds the comments of YAML and TOML files by their `#`, even inside a string.

`vale sync` downloads the package and the packages it names, so it needs network access. It copies the styles into `.vale/styles` and the package config into `.vale/styles/.vale-config/`. After the sync, `vale` runs offline. Vale reads the package config first and the repository's file last. In the repository's file, `BasedOnStyles` adds styles to the list of the package. Any other key, such as a rule level, replaces the value of the package.

To pin the exact archive, add its SHA-256 digest to the URL: `khinse-labs.zip#sha256:<digest>`. The summary of the `vale-package.yml` run shows the digest, and `vale sync --plain-progress` prints it. Only Vale 3.29.0 or later checks the digest, of this package and of the packages it names. An older Vale ignores it.

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
Grammars = yaml, toml
Vocab = Repo

[*]
BasedOnStyles = Local
SE.Semicolon = warning
write-good.Passive = NO
```

- `Local` is a style of the repository, in `.vale/styles/Local/`. The package does not use a style of that name, so `vale sync` leaves it alone.
- `Vocab = Repo` reads terms from `.vale/styles/config/vocabularies/Repo/accept.txt`. `khinse-labs.Spelling` accepts them too. Add a term for every repository to [`spelling-accept.txt`](vale/khinse-labs/styles/khinse-labs/spelling-accept.txt) instead.
- A rule level in `[*]` replaces the level of the package. `NO` turns the rule off.
- To lint the prose in `.mts` files, add `Grammars = typescript` and `[*.mts]` sections with `View = Mts` or `View = Comments`. A glob for `.mts` files does not make `vale sync` install the TypeScript grammar, so name it. The comment in the package [`.vale.ini`](vale/khinse-labs/.vale.ini) has an example. Keep `yaml, toml` in that line too (`Grammars = yaml, toml, typescript`), so that the first sync installs them.
- To read YAML or TOML files through another view, use the glob of the package: `[*.{yml,yaml}]` or `[*.toml]`. If two sections match a file, Vale picks one of them at random.
- `vale .` skips the `StylesPath`. A Vale rule file outside it goes through the `Prose` view. Vale then lints the `message`, the `description` and the test names of the rule. It does not lint the tokens or the test inputs.

### Local use

Install Vale. Then, at the root of the repository:

```sh
vale sync
vale <paths>
```

Run `vale sync` again after you change the `Packages` line. Repositories run Vale in their pre-commit hook or their task runner.

### Notes

- **Pin the package to a tag.** A new tag can bring new rules.
- **`vale-package.yml` runs when someone publishes a release.** A release made with `GITHUB_TOKEN`, such as one from `release.yml`, does not start other workflows. Then run `vale-package.yml` by hand with the tag. The build gives the same bytes for the same tag. A second run then keeps a pinned digest valid.
- **Keep immutable releases off for this repository.** `vale-package.yml` uploads the zip after the release is out, and GitHub refuses a new asset on an immutable release. To turn them on, attach the zip to the draft before you publish it.
- **Do not edit the synced styles.** `vale sync` replaces them. Change the rules here and make a new tag.
- **Each rule of `khinse-labs` and `SE` has tests.** They are under `tests:` in the rule file: one case that gives an alert and one that does not. To run them, sync the package from its folder and run `vale test --coverage` on the two styles, as the `Test the rules` step of `vale-package.yml` does. A new rule needs its two cases.
- **To update a package from the library, change its tag and its digest together** in the package `.vale.ini`. A new `Prompts` rule also needs a line in the `Prompts` section there.

## Licence

The authors dedicate the files in this repository to the public domain under [CC0 1.0](LICENSE). Copy and adapt them freely. The exception is [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md), which adapts the Contributor Covenant and stays under [<!-- vale SE.CapsPhrase = NO -->CC BY<!-- vale SE.CapsPhrase = YES --> 4.0](https://creativecommons.org/licenses/by/4.0/). The Vale package names other packages but does not contain them. `vale sync` downloads each one, with its own licence, from its repository. The word list of `khinse-labs.Weasel` comes from write-good and keeps its MIT licence, which is in the header of [`Weasel.yml`](vale/khinse-labs/styles/khinse-labs/Weasel.yml).

This licence covers this repository only. It does not apply to other khinse-labs repositories.
