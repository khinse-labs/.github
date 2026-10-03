# Contributing

These are the default guidelines for khinse-labs repositories. A repository's own `CONTRIBUTING.md` takes precedence, including its setup steps.

## Issues

Most work should start as an issue, so it is tracked and discussed before it is built. Small fixes can skip it. Blank issues are off; pick the template that fits:

| Template | Label         | Use it for                                                                  | Branch prefix |
| -------- | ------------- | --------------------------------------------------------------------------- | ------------- |
| Bug      | `bug`         | Something broken or behaving unexpectedly                                   | `fix/`        |
| Feature  | `enhancement` | New behaviour for users; acceptance criteria are required                   | `feat/`       |
| Spike    | `spike`       | An open question with a timebox, usually ending in a decision record        | `spike/`      |
| Chore    | `chore`       | Tooling, dependencies, docs, reviews and operations; no user-facing change  | `chore/`      |

Spike code is thrown away unless the issue says otherwise.

## Workflow

- **Trunk-based on `main`.** Branch off `main`, keep branches short-lived and rebase often.
- **Branch names** follow [Conventional Branch](https://conventionalbranch.org): `type/slug` in lowercase kebab-case. Put the issue number first when there is one, for example `feat/12-scan-barcode` or `fix/34-date-timezone`; without one, `chore/bump-node`.
- **Conventional Commits** are required (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`, `spike:`, and so on).
- Both are checked by [commit-check](https://commit-check.com) against [`cchk.toml`](cchk.toml), which every repository inherits: locally by the Git hooks in [`lefthook/conventions.yml`](lefthook/conventions.yml) (install [uv](https://docs.astral.sh/uv/) first), and on pull requests by the Commit Check GitHub App.
- Do not skip Git hooks. If a hook fails, fix the cause.

## Pull requests

- **Keep PRs small** and focused on one concern.
- **Tests with every feature.** New behaviour ships with tests; bug fixes ship with a regression test.
- **Docs in the same PR.** If a change affects behaviour, setup or architecture, update the docs in the same PR.
- The repository's checks must pass.
- Fill in the pull request template, including `Closes #<issue>` when there is one.

### Merging

- PRs are **squash merged**, so the PR title must be a valid Conventional Commit (the App checks the squash message on every PR).
- **Only maintainers merge.** Contributors and AI agents open PRs but never merge them and never push directly to `main`.

## Getting help

See [SUPPORT.md](SUPPORT.md). Report security issues privately as described in [SECURITY.md](SECURITY.md).
