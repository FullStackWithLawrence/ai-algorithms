---
name: ai-algorithms-ci
description: Use when changing or troubleshooting ai-algorithms' GitHub Actions workflows (test.yml, release.yml, precommitVersionBumps.yml, auto-assign.yml), semantic-release (release.config.js, package.json, CHANGELOG.md, tags), Dependabot (.github/dependabot.yml) or Mergify (.mergify.yml), or when asked why a workflow run failed. Covers what each workflow does and needs, how to read a failed run with gh, the release branches, the PAT secret, the CI skip trap, and what never to trigger yourself.
---

# CI and Releases

## The workflows

| Workflow                    | Trigger                                  | What it does                                                                                       |
| --------------------------- | ---------------------------------------- | -------------------------------------------------------------------------------------------------- |
| `test.yml`                  | every pull request; pushes to main, next | Runs every pre-commit hook on every file (Python 3.13, `requirements/local.txt`). Job `pre-commit` |
| `release.yml`               | push to `main`, `workflow_dispatch`      | semantic-release: version, `CHANGELOG.md`, tag, GitHub release; then pushes the major branch `vN`  |
| `precommitVersionBumps.yml` | weekly cron (Wed 00:00 UTC), dispatch    | `pre-commit autoupdate` on `alpha`; commits and pushes `.pre-commit-config.yaml` if it changed     |
| `auto-assign.yml`           | issue or pull request opened             | Assigns it to the maintainer                                                                       |

There's no Python package, so there's no `__version__.py` and no version-bump
workflow for alpha and beta (azureml-example has one because it has a
package). There are no unit tests either; `test.yml` is the lint check.

Conventions shared with azureml-example (keep them):

- A header comment says what the workflow does and why.
- `permissions: contents: read` at the top; writes use the `PAT` secret.
- Every action is pinned to a commit SHA with its version in a comment
  (`actions/checkout@<sha> # v7.0.1`). Dependabot's `github-actions` updates
  bump them. Copy SHAs from azureml-example's workflows when adding a step.
- `timeout-minutes` on every job; `concurrency` where runs could overlap.
- Step outputs go to `"$GITHUB_OUTPUT"`, never `::set-output` (removed).
- `actions/setup-node` without `node-version: latest`: "latest" can be a
  pre-release Node that semantic-release refuses to run on.
- No `pull_request_target`. A fork's pull request runs its own code with
  `pull_request`, without the repository's secrets. Point out to the user any
  fork pull request that changes `.github/`: once merged, it runs with them.

## semantic-release

- `release.config.js` is the one place that lists the release branches
  (`main`, `next`, prereleases `beta` and `alpha`) and plugins. Workflows
  don't repeat the branch list.
- `feat` makes a minor release, `fix` and `perf` a patch, `BREAKING CHANGE`
  a major; `docs`, `test`, `style` and `refactor` make none (`releaseRules`).
- The release commit is `chore(release): <version>` with **no CI skip
  instruction**, so that the pull request from alpha to main still runs its
  checks; `release.yml` skips its own commit with an `if:` instead.
- The `@semantic-release/git` plugin commits `CHANGELOG.md`, `package.json`,
  `package-lock.json` and `requirements/**/*`.
- `package.json` holds only semantic-release, its plugins,
  `conventional-changelog-conventionalcommits` (the preset it uses) and
  Prettier.

## Dependabot and Mergify

Dependabot opens monthly pull requests for `requirements/` (pip), npm and
GitHub Actions. Mergify approves and merges Dependabot's pull requests into
`main` once checks pass, and each merge is a release (`chore(deps)` commits
release nothing, a `fix(deps)` would). A Dependabot pull request that only
edits a `.in` constraint leaves the compiled `.txt` stale; recompile
(`ai-algorithms-python-environment`).

## Troubleshooting a failed run

Read-only commands, fine to run:

```bash
gh run list --status failure --limit 20
gh run view <run-id>                        # jobs and the failing step
gh run view <run-id> --log-failed | cut -f3- | tail -40
```

Then find the cause in the repository, not in the runner: most failures here
have been template leftovers (a file the workflow expects that this
repository doesn't have). Check every path a workflow names
(`requirements/*.txt`, a package folder, a branch) against `git ls-files`.
A scheduled workflow runs the default branch's copy of the file (`main`), so a
fix on `alpha` doesn't reach the cron run until it's merged.

## What needs the user

Never run these yourself; give the user the command:
`gh workflow run`, `gh run rerun`, `gh run cancel`, `gh release create|delete`,
`make release`, `npx semantic-release` without `--dry-run`, `git push`,
deleting branches or tags, and changes to repository settings, secrets or
rulesets. `npx semantic-release --dry-run --no-ci` needs a GitHub token and
pushes nothing; still ask before running it.
