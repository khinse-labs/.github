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
| [`.github/workflows/`](.github/workflows/) | Reusable workflows: main guard, PR title and labels sync |
| [`workflow-templates/`](workflow-templates/) | Caller templates for those workflows, under Actions > New workflow |
| [`labels.yml`](labels.yml) | The standard label set that labels sync applies |
| [`profile/README.md`](profile/README.md) | The organisation's public landing page |

## Shared workflows

Private repositories on the Free plan have no branch protection, rulesets or environments, so the checks live here as reusable workflows (this repository is public, so private repositories can call them). Each takes an optional `runs-on` input (default `ubuntu-latest`).

| Workflow | Called on | What it does |
| --- | --- | --- |
| [`main-guard.yml`](.github/workflows/main-guard.yml) | `push` to the default branch | Opens a `direct-push` issue when the pushed commit is not part of a merged pull request, or the push was forced |
| [`pr-title.yml`](.github/workflows/pr-title.yml) | `pull_request` | Fails when the title is not a Conventional Commit, using the rules of [`cchk.toml`](cchk.toml) |
| [`labels-sync.yml`](.github/workflows/labels-sync.yml) | `workflow_dispatch`, `schedule` | Creates and updates the labels of [`labels.yml`](labels.yml); never deletes one |

A repository adopts them by copying the templates from **Actions > New workflow** (or from [`workflow-templates/`](workflow-templates/)), or by creating it from `repo-template`, which already has them. The caller grants the permissions each job needs; see the templates.

## Notes for maintainers

- If a repository has its own `.github/ISSUE_TEMPLATE/` folder, none of these issue forms are used there.
- The issue forms set the org issue types Bug, Feature and Task. They apply no labels and add issues to no project: each product's own project adds its repository's issues with its auto-add workflow.
- Licences cannot be set here; add a `LICENSE` to each repository.
- Organisation settings (new repositories, labels, product projects) are documented in the README of the Pantry Dex project, visible to organisation members.
- This repository must stay public for the defaults to apply.

See GitHub's guide to [default community health files](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/creating-a-default-community-health-file).

## Licence

The files in this repository are dedicated to the public domain under [CC0 1.0](LICENSE). Copy and adapt them freely. The exception is [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md), which is adapted from the Contributor Covenant and stays under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

This licence covers this repository only. It does not apply to other khinse-labs repositories.
