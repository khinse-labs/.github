# Contributing

These are the default guidelines for khinse-labs repositories. A repository's own `CONTRIBUTING.md` takes precedence, including its setup steps.

## Issues

Most work should start as an issue, so it is tracked and discussed before it is built. Small fixes can skip it. Blank issues are off; pick the form that fits. Each form sets the issue type, and the product's project picks the issue up automatically:

| Form    | Issue type | Use it for                                                                 |
| ------- | ---------- | -------------------------------------------------------------------------- |
| Bug     | Bug        | Something broken or behaving unexpectedly                                  |
| Feature | Feature    | New behaviour for users; acceptance criteria are required                  |
| Task    | Task       | Tooling, dependencies, docs, reviews and operations; no user-facing change |

Releases are milestones. Split a big feature into sub-issues.

### Project board

Each product has its own project. Every issue moves through its Status field: **Backlog → Ready → In progress → In review → Done**.

- A Feature lists what is still unknown under **Open questions**, one checklist item each. Business calls, such as who owns an account, go on the first feature that needs them.
- Tick a question with a link to the comment that answers it, or with "settle in PR".
- An issue moves from Backlog to Ready only when every box is ticked.

### Labels

Labels are managed by hand in the GitHub UI, and no Action creates or applies them. Set them by hand at triage:

- `accessibility`, `documentation`, `good first issue`, `help wanted`.
- Area labels, one broad word each (`ui`, `api`, `data`, `auth`, `i18n`, `privacy`, `security`, `performance`, `ci`). Maintainers add one when it is first needed.

## Workflow

- **Trunk-based on `main`.** Branch off `main`, keep branches short-lived and merge `main` in to catch up. Force pushes are blocked; the squash merge keeps `main` linear.
- **Branch names follow [Conventional Branch](https://conventionalbranch.org)**: `type/slug` with the issue number first, such as `feat/12-scan-barcode`. The type is `feat`, `fix`, `docs` or `chore` (anything else, such as a refactor or CI change). Tool names such as `claude/...` or GitHub's "Create a branch" (`12-scan-barcode`) fail, so rename those branches. Renovate and Dependabot branches are not checked.
- **Conventional Commits** are required (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`, and so on).
- They are checked by [commit-check](https://commit-check.com) against [`cchk.toml`](cchk.toml): on pull requests by the Commit Check GitHub App, and locally by the Git hooks in [`lefthook/conventions.yml`](lefthook/conventions.yml), which each repository loads from its `lefthook.yml` and its own `cchk.toml` inherits. Install [uv](https://docs.astral.sh/uv/) and lefthook (`uv tool install lefthook`), then run `lefthook install` in each clone. The hooks check the message on commit-msg, the branch name and author on pre-commit, and tag names, committed files and force pushes on pre-push.
- Do not skip Git hooks. If a hook fails, fix the cause.

## Pull requests

- **Keep PRs small** and focused on one concern.
- **Tests with every feature.** New behaviour ships with tests; bug fixes ship with a regression test.
- **Docs in the same PR.** If a change affects behaviour, setup or architecture, update the docs in the same PR.
- **Decisions ship in the PR.** A decision record or doc change goes in the same PR as the code that needed it. There are no doc-only decision PRs.
- The repository's checks must pass.
- Fill in the pull request template, including `Closes #<issue>` when there is one.

### Merging

- PRs are **squash merged**, so the PR title must be a valid Conventional Commit (the App checks the squash message on every PR).
- **Only maintainers merge.** Nobody pushes directly to `main`; every change lands through a PR.
- **Agents act for a person.** An AI agent may do anything its person can do, such as open, triage or merge. Each person is responsible for what their agents do.

## Getting help

See [SUPPORT.md](SUPPORT.md). Report security issues privately as described in [SECURITY.md](SECURITY.md).
