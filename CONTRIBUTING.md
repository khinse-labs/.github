# Contributing

These are the default guidelines for khinse-labs repositories. A repository's own `CONTRIBUTING.md` takes precedence, including its setup steps.

## Issues

Most work should start as an issue, to track and discuss it before building it. Small fixes can skip it. Blank issues are off. Pick the form that fits. Each form sets the issue type, and the product's project picks the issue up automatically:

| Form    | Issue type | Use it for                                                                      |
| ------- | ---------- | ------------------------------------------------------------------------------- |
| Bug     | Bug        | Something broken or not behaving as expected                                    |
| Feature | Feature    | New behaviour for users, with required acceptance criteria                      |
| Task    | Task       | Tooling, dependencies, docs, reviews and operations, with no user-facing change |

Releases are milestones. Split a big feature into sub-issues.

### Project board

Each product has its own project. The Status field of each issue moves through **Backlog → Ready → In progress → In review → Done**.

- A Feature lists what is still unknown under **Open questions**, one checklist item each. Business calls, such as the owner of an account, go on the first feature that needs them.
- Tick a question with a link to the comment that answers it, or with "settle in PR".
- An issue moves from Backlog to Ready when every box has a tick, and not before.

### Labels

The organisation uses GitHub's default labels: `bug`, `documentation`, `duplicate`, `enhancement`, `good first issue`, `help wanted`, `invalid`, `question` and `wontfix`. Maintainers apply them by hand at triage. Actions do not create or apply them.

## Workflow

- **Trunk-based on `main`.** Branch off `main`, make each branch short-lived, and merge `main` in to catch up. Force pushes fail, and the squash merge keeps `main` linear.
- **Branch names follow [Conventional Branch](https://conventionalbranch.org)**: `type/slug` with the issue number first, such as `feat/12-scan-barcode`. The type is `feat`, `fix`, `docs` or `chore` (anything else, such as a refactor or CI change). Tool names such as `claude/...` or GitHub's "Create a branch" (`12-scan-barcode`) fail, so rename those branches. Renovate and Dependabot branches are not checked.
- **Write Conventional Commits** (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`, and so on).
- [commit-check](https://commit-check.com) checks them against [`cchk.toml`](cchk.toml). On pull requests, the Commit Check GitHub App runs it. Locally, the Git hooks in [`lefthook/conventions.yml`](lefthook/conventions.yml) run it. Each repository loads these hooks from its `lefthook.yml`, with a `.lefthook/cchk.toml` that inherits these rules. Install [uv](https://docs.astral.sh/uv/), lefthook (`uv tool install lefthook`) and [mise](https://mise.jdx.dev/), then run `lefthook install` in each clone. The hooks check the message on commit-msg, the branch name, the author and the share of comments on pre-commit, and tag names, committed files and force pushes on pre-push.
- Do not skip Git hooks. If a hook fails, fix the cause.

## Pull requests

- **Make PRs small** and focused on one concern.
- **Tests with every feature.** New behaviour comes with tests, and a bug fix comes with a regression test.
- **Docs in the same PR.** If a change affects behaviour, setup or architecture, update the docs in the same PR.
- **Decisions belong in the PR.** A decision record or doc change goes in the same PR as the code that needed it. To record a decision, do not open a PR that changes docs and no code.
- The repository's checks must pass.
- Fill in the pull request template, including `Closes #<issue>` if an issue exists.

### Merging

- PRs are **squash merged**, so the PR title must be a valid Conventional Commit (the App checks the squash message on every PR).
- **Maintainers merge, and nobody else does.** Nobody pushes directly to `main`. Every change lands through a PR.
- **Agents act for a person.** An AI agent may do anything its person can do, such as open an issue or PR, triage, or merge. Each person answers for what their agents do.

## Getting help

See [SUPPORT.md](SUPPORT.md). Report security issues privately as described in [SECURITY.md](SECURITY.md).
