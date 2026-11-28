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
| `include-paths` | empty | Globs, separated by spaces or newlines, passed to git-cliff as `--include-path`. Commits that touch these paths count for the version and the notes, and no others do (such as `apps/app/** packages/**`). Empty counts every commit. |
| `cliff-ref` | `v0.1.0` | Tag of this repository to read `cliff.toml` from. The caller pins the workflow itself by tag. Then a new workflow tag is the one way to change the default. Set it to read another tag. |

| Output | Meaning |
| --- | --- |
| `released` | `true` when the workflow made a release, `false` when there was nothing to release. |
| `tag` | The new tag, such as `v1.2.3`. Empty if the workflow did not release. |
| `version` | The new version without the `v`, such as `1.2.3`. Empty if the workflow did not release. |

### Notes

- **Pin the caller to a tag, such as `@v0.1.0`.** Callers pin the shared config to tags of this repository (`cchk.toml`, `lefthook/conventions.yml`, `cliff.toml`), and the workflow follows the same rule. `v0.1.0` is the first tag of this workflow. The maintainers create it right after the workflow merges.
- **Keep the default of `cliff-ref` on a tag that exists.** If a change to `cliff.toml` alters versions or notes, merge it and make the tag. Then raise the default in a new PR and make a new tag. A change that touches comments and nothing else does not need a new default.
- **The calling job needs `contents: write`.** A called workflow cannot use a permission that its caller does not give it. Keep `permissions: contents: read` for the rest of the caller.
- **A release made with `GITHUB_TOKEN` does not start other workflows.** Workflows on `release` or on a pushed tag do not run. Deploy in a job of the caller instead. That job has `needs:` for the release job and reads `tag` (see the example). Do not deploy in a separate workflow on the tag.
- **The default branch can release, and no other ref can.** The workflow fails on any other ref before it checks anything out, and on a tag-triggered caller.
- **One release at a time.** The called job has `concurrency: group: release` without cancelling. Do not use the group `release` in the caller: the same group in both deadlocks.
- **A tag ruleset can block it.** If the repository restricts who creates `v*` tags, `github-actions` needs a bypass, because the workflow creates the tag with `GITHUB_TOKEN`.
- **One call makes the tag and the release.** A cancelled or timed-out run cannot leave a tag with no release. The tag is lightweight, not annotated.
- [uv](https://docs.astral.sh/uv/) installs git-cliff from PyPI. The workflow pins the third-party actions by commit SHA, and uv and git-cliff by exact version. PyPI does not let an owner replace the files of a version. The workflow does not check hashes of the git-cliff files.

## Shared Vale config

[`vale/khinse-labs/`](vale/khinse-labs/) is a [Vale package](https://docs.vale.sh/keys/packages) with the prose config for every repository in the organisation. It has no rules of its own. It holds a [`.vale.ini`](vale/khinse-labs/.vale.ini) that pins packages and sets rule levels, and a `config` folder with a vocabulary and views. The `.vale.ini` names packages from the [Vale package library](https://vale.sh/explorer), and `vale sync` installs them too:

| Package | What it adds |
| --- | --- |
| `write-good` | Passive voice, wordy phrases, weasel words, adverbs, clichés, "so" at the start of a sentence, sentences that start with "there is" and repeated words |
| `Readability` | The Automated Readability Index of each paragraph of 25 words or more. It gives an error above 9, although the message says "below 8", and inline code does not count toward it. In a commit body, put identifiers and paths in backticks, because a bare one raises the score. |
| `Prompts` | Checks for instruction files for agents |
| `Modelese` | Phrases that language models overuse |
| `ai-tells` | More patterns of generated prose |
| `alex` | Words that are not inclusive |
| `Commits` | Checks for commit messages, described [below](#commit-messages) |

The `.vale.ini` turns the styles and Vale's own style on for every file. `Prompts` checks the instruction files for agents and no other file. These are `AGENTS.md`, `CLAUDE.md` and `SKILL.md` files, and the Markdown files under `.claude/agents/`, `.claude/commands/` and `.claude/rules/`. `Commits` is on for commit messages and off for all other files. Every rule that is on gives an error. It pins each package to a release and to the SHA-256 of its archive. [`vale-package.yml`](.github/workflows/vale-package.yml) checks that the packages install, then packs the folder as `khinse-labs.zip` and attaches it to each release of this repository.

`Vale.Spelling` checks the spelling, and a misspelling is an error. The terms that it accepts in every repository are in the vocabulary [`accept.txt`](vale/khinse-labs/styles/config/vocabularies/khinse-labs/accept.txt). It also accepts a word with an underscore inside it, such as `git_url`, because such a word is an identifier. `Vale.khinse-labs.Terms` asks for the exact case of an entry, such as `TSDoc` or `Quarkus`. An entry that starts with `(?i)`, such as `(?i)env`, accepts any case, and the Terms rule leaves it alone.

Vale lints the prose of more than Markdown:

- **YAML and TOML files.** The `Prose` view in `config/views` picks their comments and the string values of some keys, at any depth. The keys are `name`, `description`, `title`, `summary`, `label`, `placeholder`, `message` and `about`. It also picks the items of an `options` list. Examples are manifests, issue forms and workflow inputs. Other keys, ids and `run:` scripts are not linted.
- **Front matter.** Vale lints each top-level string value of the YAML front matter of a Markdown file by default, such as the `description` of a `SKILL.md`. It does not lint nested values or lists there.

Vale skips every file named `CODE_OF_CONDUCT.md`, in any folder. Such a file is the Contributor Covenant under CC BY 4.0. A rewrite to pass the rules would change the licensed text.

### Repository config

A repository adds the package to the `.vale.ini` at its root:

```ini
StylesPath = .vale/styles
Packages = https://github.com/khinse-labs/.github/releases/download/<tag>/khinse-labs.zip
Grammars = yaml, toml, typescript, bash
```

The package names the same grammars, but the first `vale sync` installs the grammars in the repository's file and no others. Without them, Vale finds comments by their delimiter (`#`, `//`), even inside a string. Vale does not install a grammar that is not in the list. Add the grammar of each other language that the repository lints, such as `python`.

`vale sync` downloads the package and the packages it names, so it needs network access. It copies the styles into `.vale/styles` and the package config into `.vale/styles/.vale-config/`. After the sync, `vale` runs offline. Vale reads the package config first and the repository's file last. In the repository's file, `BasedOnStyles` adds styles to the list of the package. Any other key, such as a rule level, replaces the value of the package.

To pin the exact archive, add its SHA-256 digest to the URL: `khinse-labs.zip#sha256:<digest>`. The summary of the `vale-package.yml` run shows the digest, and `vale sync --plain-progress` prints it. Vale 3.29.0 or later checks the digest, of this package and of the packages it names. An older Vale ignores it.

Git-ignore what `vale sync` writes. If the repository has no styles of its own, ignore `.vale/styles/`. Otherwise ignore everything except your own files:

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
Grammars = yaml, toml, typescript, bash
Vocab = Repo

[*]
BasedOnStyles = Local
ai-tells.SemicolonUsage = warning
write-good.Passive = NO
```

- `Local` is a style of the repository, in `.vale/styles/Local/`. The package does not use a style of that name, so `vale sync` leaves it alone.
- `Vocab = Repo` reads terms from `.vale/styles/config/vocabularies/Repo/accept.txt`. `Vale.Spelling` accepts them too, and `Vale.Terms` asks for the exact case of each entry. Start an entry with `(?i)` to accept any case. Add a term for every repository to the vocabulary [`accept.txt`](vale/khinse-labs/styles/config/vocabularies/khinse-labs/accept.txt) of the package instead.
- A rule level in `[*]` replaces the level of the package. `NO` turns the rule off.
- To lint the prose in `.mts` files, add `[*.mts]` sections with `View = Mts` or `View = Comments`. These views need the TypeScript grammar, which the `Grammars` line above installs. The comment in the package [`.vale.ini`](vale/khinse-labs/.vale.ini) has an example.
- To read YAML or TOML files through another view, use the glob of the package: `[*.{yml,yaml}]` or `[*.toml]`. If two sections match a file, Vale picks one of them at random.
- `vale .` skips the `StylesPath`. A Vale rule file outside it goes through the `Prose` view. Vale then lints the `message`, the `description` and the test names of the rule. It does not lint the tokens or the test inputs.

### Local use

Install Vale. Then, at the root of the repository:

```sh
vale sync
vale <paths>
```

Run `vale sync` again after you change the `Packages` line. Repositories run Vale in their pre-commit hook or their task runner.

### Commit messages

The `[COMMIT_EDITMSG]` section of the package checks commit messages, together with commit-check. Vale reads the message from stdin, and `--path=COMMIT_EDITMSG` picks the section:

```sh
git log -1 --format=%B | vale --path=COMMIT_EDITMSG
```

| Check | Tool |
| --- | --- |
| The type, the subject length (5 to 72 characters) and its lower-case start | commit-check |
| Merge, revert and fixup commits pass, WIP and empty commits fail | commit-check |
| Branch names, authors, tag names, files and force pushes | commit-check |
| A blank line after the subject (`Commits.Blank`) | Vale, error |
| A subject in the imperative: "add", not "added" (`Commits.Imperative`) | Vale, error |
| No placeholder subject, such as `fix: typo` or `chore: update` (`Commits.Placeholder`) | Vale, error |
| No whitespace at the edges of the subject (`Commits.Whitespace`) | Vale, error |
| A space after the colon and no empty scope (`Conventional.Space`, `Conventional.Scope`) | Vale, error |
| Footers after a blank line, `BREAKING CHANGE:` in capitals and a hyphen in place of a space in a token (`Conventional.Footer`, `Conventional.Breaking`, `Conventional.Token`) | Vale, error |
| Body lines of 72 characters at most, except a line with a URL and a footer line (`SevenRules.Wrap`) | Vale, error |
| No trailing whitespace in the body and no tab (`Gitlint.BodyTrailingWhitespace`, `Gitlint.HardTab`) | Vale, error |
| The prose rules that the package turns on, on the subject and the body | Vale, error |

Every alert on a message is an error and stops the commit. The prose rules are the rules of `[*]`, with these changes for messages:

- 17 ai-tells rules are off. On past commit messages, all or nearly all their alerts were false. `ai-tells.ColonUsage` would stop every commit with a `Co-Authored-By:` trailer, and `ai-tells.ConsequenceClause` flags ", so", which a body needs to give a reason. The comment in the package `.vale.ini` lists the rest.
- `Vale.Spelling` and the vocabulary case check are off, because a message names identifiers, tools and package names.
- `alex.ProfanityUnlikely` is off. It reports "failed" and "failure".
- All write-good rules are on, also the ones that `[*]` turns off.

The section of the package sets its own rule levels, so a level in the `[*]` section of a repository does not reach commit messages. To change a level for messages, set it in a `[COMMIT_EDITMSG]` section of the repository's `.vale.ini`.

[`lefthook/conventions.yml`](lefthook/conventions.yml) runs Vale in the commit-msg hook, after commit-check. Like commit-check, the job lets merge, revert, fixup and squash commits through. In a repository without a `.vale.ini`, the job does nothing. In a repository with one, the job needs Vale and a `vale sync`, and it fails without them. It also needs a package tag that has the `[COMMIT_EDITMSG]` section. With an older package, `[*]` checks the message as plain text, and its errors stop the commit.

The commit hook of the agent-tools Claude Code plugin uses the same `[COMMIT_EDITMSG]` section.

### Notes

- **Pin the package to a tag.** A new tag can bring new rules.
- **`vale-package.yml` runs when someone publishes a release.** A release made with `GITHUB_TOKEN`, such as one from `release.yml`, does not start other workflows. Then run `vale-package.yml` by hand with the tag. The build gives the same bytes for the same tag. A second run then keeps a pinned digest valid.
- **Keep immutable releases off for this repository.** `vale-package.yml` uploads the zip after the release is out, and GitHub refuses a new asset on an immutable release. To turn them on, attach the zip to the draft before you publish it.
- **Do not edit the synced styles.** `vale sync` replaces them. Change the config here and make a new tag.
- **To update a package from the library, change its tag and its digest together** in the package `.vale.ini`. A new `Prompts` rule also needs a line in the `Prompts` section there. Keep `Commits` first in the list. The comment above `Packages` says why.

## Licence

The authors dedicate the files in this repository to the public domain under [CC0 1.0](LICENSE). Copy and adapt them freely. The exception is [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md), which is the text of the Contributor Covenant 2.1 with our contact method filled in. It stays under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). The Vale package names other packages but does not contain them. `vale sync` downloads each one, with its own licence, from its repository.

This licence covers this repository alone. It does not apply to other khinse-labs repositories.
