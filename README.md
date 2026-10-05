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

## Notes for maintainers

- If a repository has its own `.github/ISSUE_TEMPLATE/` folder, none of these issue forms are used there.
- The issue forms set the org issue types Bug, Feature and Task, and add each issue to the org's Roadmap project (`khinse-labs/1`). They apply no labels; see [Labels](#labels).
- The person opening an issue needs write access to the Roadmap project for the issue to be added to it. Turn on the project's auto-add workflow to catch issues from anyone else.
- Licences cannot be set here; add a `LICENSE` to each repository, or create new repositories from [`khinse-labs/repo-template`](https://github.com/khinse-labs/repo-template).
- This repository must stay public for the defaults to apply.

See GitHub's guide to [default community health files](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/creating-a-default-community-health-file).

## Organisation settings

Repository settings, labels, rulesets and the Roadmap project are managed by hand in the GitHub UI. They used to be managed as code in `khinse-labs/infra`, which is now archived. Record any change to them here, in a PR.

### New repository

1. Create it from [`khinse-labs/repo-template`](https://github.com/khinse-labs/repo-template).
2. In Settings → General:
   - Features: issues on, projects on, wiki off, discussions off.
   - Pull requests: squash merging only (merge commits and rebase merging off), with the default commit message set to the pull request title and commit messages.
   - Always suggest updating pull request branches off, allow auto-merge off, automatically delete head branches on.
3. In Settings → Advanced Security: Dependabot alerts on.
4. On a public repository, in Settings → Rules → Rulesets (GitHub Free allows rulesets on public repositories only):
   - **Default branch**: active, targeting the default branch, with no bypass list. Require a pull request with 0 approvals and conversation resolution, allowed merge method squash only. Require the status check `Commit Check` from the Commit Check app, plus the repository's own CI checks from GitHub Actions. Block force pushes and deletion, and require linear history.
   - **Release tags**: active, targeting tags matching `refs/tags/v*.*.*`. Restrict updates and deletion, so a release tag never moves or disappears.
5. Link it to the [Roadmap](https://github.com/orgs/khinse-labs/projects/1) project (the repository's Projects tab → Link a project).

### Roadmap project

The org's [Roadmap](https://github.com/orgs/khinse-labs/projects/1) project was created from GitHub's "Team planning" template. Issues reach it through the `projects:` key in the issue forms.

- **Status** options: Backlog, Ready, In progress, In review, Done.
- **Fields**: the template's Estimate, Iteration, Start date, Target date, Priority and Size are removed. Priority (P0, P1, P2) and Size (S, M, L) get added back the first time the Ready column is hard to sort.
- **Views**: every view shows every item, with no saved filter; they differ only in layout, grouping and sort.
  - Board: board, columns by Status, Backlog included.
  - Releases: table grouped by Milestone.
  - Triage: table sorted by Created, newest first, with Milestone and Type visible.
- **Workflows** turned on: Item added to project → Backlog; Item reopened → Backlog; Pull request linked to issue → In review; Code changes requested → In progress; Item closed → Done; Pull request merged → Done; Auto-close issue; Auto-add sub-issues to project; Auto-archive items (closed issues not updated for 2 weeks). Code review approved is off.

### Labels

The org default labels (Org settings → Repository defaults → Repository labels) are what new repositories start with: `accessibility`, `documentation`, `good first issue` and `help wanted`.

Area labels are broad single words: `ui`, `api`, `data`, `auth`, `i18n`, `privacy`, `security`, `performance`, `ci`. Add one by hand when it is first needed, both to the org defaults and to each existing repository.

No Action ever creates or applies labels; set them by hand at triage. Renaming a label keeps it on issues; deleting it removes it everywhere, so search issues for `label:<name>` first.

## Licence

The files in this repository are dedicated to the public domain under [CC0 1.0](LICENSE). Copy and adapt them freely. The exception is [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md), which is adapted from the Contributor Covenant and stays under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

This licence covers this repository only. It does not apply to other khinse-labs repositories.
