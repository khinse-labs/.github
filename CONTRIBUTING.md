# Contributing

These are the default guidelines for khinse-labs repositories. A repository's own `CONTRIBUTING.md` takes precedence, including its setup steps.

## Issues

Every piece of work starts as an issue. Blank issues are off; pick the template that fits:

| Template | Label         | Use it for                                                                  | Branch prefix |
| -------- | ------------- | --------------------------------------------------------------------------- | ------------- |
| Bug      | `bug`         | Something broken or behaving unexpectedly                                   | `fix/`        |
| Feature  | `enhancement` | New behaviour for users; acceptance criteria are required                   | `feat/`       |
| Spike    | `spike`       | An open question with a timebox, usually ending in a decision record        | `spike/`      |
| Chore    | `chore`       | Tooling, dependencies, docs, reviews and operations; no user-facing change  | `chore/`      |

Spike code is thrown away unless the issue says otherwise.

## Workflow

- **Trunk-based on `main`.** Branch off `main`, keep branches short-lived and rebase often.
- **Branch names:** `type/<issue>-slug`, for example `feat/12-scan-barcode` or `fix/34-date-timezone`. Every branch starts from an issue.
- **Conventional Commits** are required (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`, and so on).
- Do not skip Git hooks. If a hook fails, fix the cause.

## Pull requests

- **Keep PRs small** and focused on one issue.
- **Tests with every feature.** New behaviour ships with tests; bug fixes ship with a regression test.
- **Docs in the same PR.** If a change affects behaviour, setup or architecture, update the docs in the same PR.
- The repository's checks must pass.
- Fill in the pull request template, including `Closes #<issue>`.

### Merging

- PRs are **squash merged**, so the PR title must be a valid Conventional Commit.
- **Only maintainers merge.** Contributors and AI agents open PRs but never merge them and never push directly to `main`.

## Getting help

See [SUPPORT.md](SUPPORT.md). Report security issues privately as described in [SECURITY.md](SECURITY.md).
