---
name: ai-algorithms-pull-requests
description: Use when asked to create, open, write or update a GitHub pull request in FullStackWithLawrence/ai-algorithms, or to review or describe a contributor's pull request (often a notebook change from a fork, or a Dependabot update). Covers the branches, the title, filling in every section of .github/PULL_REQUEST_TEMPLATE.md from the commits' own messages, creating it with gh pr create --body-file, the checks that run on pull requests, and what never to do (push, merge, leave placeholders in).
---

# Pull Requests

The repository is `FullStackWithLawrence/ai-algorithms`. Every pull request
uses [.github/PULL_REQUEST_TEMPLATE.md](../../.github/PULL_REQUEST_TEMPLATE.md).
`gh pr create --body-file` doesn't pre-fill it, so fill in every section from
the commits themselves.

## Rules

- **Create one only when asked.** A pull request is public and notifies
  people. Writing the description as text is fine when that's all the user
  asked for.
- **Never push, merge, or change a branch.** If the head branch isn't on
  GitHub, or is behind the local one, say so and stop.
- **Never leave a placeholder** (`Fixes #[Add issue number here.]`,
  `_Describe what this Pull Request does_`). Each section gets content or a
  plain "None.".
- **The repository is public.** No keys, subscription ids or personal details.
- **No bare `@name`** unless you mean to notify that GitHub user.
- **No CI skip instruction** anywhere (see `ai-algorithms-git-commits`).

## Branches and title

- Work lands on `main` (the default) and every merge to `main` can release.
  `alpha` is where the maintainer works and where the weekly pre-commit
  version bumps land; `beta` and `next` are semantic-release branches too.
  Ask which base the user wants if it isn't obvious.
- The title is the main commit's subject, a conventional commit.
- Check for an open one first:
  `gh pr list --repo FullStackWithLawrence/ai-algorithms --head <branch>`.
  If there is one, update it with `gh pr edit <n> --body-file ...`.

## Gather the material

```bash
git fetch origin
git status -sb
git log --oneline origin/main..<branch>
git log --format='### %h %s%n%n%b' origin/main..<branch>
git diff --stat origin/main...<branch> | tail -1
```

Leave out `chore(release)` and merge commits. Read every commit body.

## Fill in the template

Keep its headings and order, drop the `<!-- -->` hints.

- **Type of Change:** check every box a commit earns: `feat` = New feature,
  `fix` = Bug fix, `docs` (and notebook prose) = Documentation, `refactor` =
  Refactor, `ci`/`build`/`chore`/`test` = Chore.
- **Resolves:** one `- Fixes #<n>` per issue a commit names, or `- None.`
- **Changes:** a sentence or two on the whole, then a `###` subsection per
  commit (subject and short hash) with the problem and bullets naming files.
- **Testing:** what ran and how: pre-commit hooks, notebooks run by hand (which
  cells, which kernel), workflows observed on GitHub. Never claim a check
  nobody ran.
- **Screenshots:** for notebook plots; otherwise `None: no visible change.`
- **Dependencies:** changed pins in `requirements/`, new secrets (CI uses
  `PAT`), new datasets a reader must download. Otherwise `None.`
- **Breaking Changes:** renamed or removed notebooks, a new Python version,
  removed make targets. Otherwise `None.`

End with the attribution line from the conversation's system context, if any.

## What runs on a pull request

- `test.yml` (`pull_request`): job `pre-commit` runs every hook on every file.
- `auto-assign.yml`; Mergify approves and merges Dependabot pull requests into
  `main`.

## Create it

```bash
gh pr create --repo FullStackWithLawrence/ai-algorithms --base main --head <branch> \
  --title "<type>(<scope>): <subject>" --body-file <scratchpad>/pr-body.md
```

Write the body to a file in your scratchpad first. Give the user the url, and
say what you couldn't verify.
