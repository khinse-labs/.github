# Governance

## Maintainers

The khinse-labs maintainers run the khinse-labs repositories. They:

- set direction and priorities,
- make final decisions on design, architecture and scope,
- review and merge all pull requests,
- cut releases.

## Decisions

Each repository records its major decisions as architecture decision records (ADRs).

Each ADR has a status:

- **Proposed:** open for discussion, not yet in effect.
- **Accepted:** agreed and in effect.
- **Superseded:** replaced by a later ADR, which it links to.

Accepted ADRs are not rewritten. To change a decision, write a new ADR that supersedes the old one.

An ADR, or any doc change that records a decision, goes in the same PR as the code that applies it.

## Contributors and AI agents

- Contributors may open issues and pull requests.
- Maintainers merge, and nobody else does. They use squash merges. Nobody pushes directly to `main`.
- **An AI agent may do anything its person can do**, such as open an issue or PR, triage, or merge. Each person answers for what their agents do.

See [CONTRIBUTING.md](CONTRIBUTING.md) for the workflow and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for expected behaviour.
