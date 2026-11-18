# CLAUDE.md

Guidance for Claude Code (and other coding agents) working in this repository.

ai-algorithms is a teaching repository from Full Stack With Lawrence: Jupyter
notebooks that demonstrate basic AI algorithms in Python (anomaly detection,
regression, k-means clustering), used in university courses and YouTube
tutorials. There is no Python package and no unit test suite; the notebooks
are the product. Clarity matters as much as correctness.

Detailed know-how lives in the Agent Skills under `skills/` (symlinked to
`.claude/skills`). **Load `ai-algorithms-development` first for any change.**
Its table says which narrower `ai-algorithms-*` skill covers each kind of work.
This file holds only what applies to nearly every task.

## Hard rules

1. **Never run git write commands.** "Write a git commit" means print the
   command as text. Never run `git commit`, `git add`, `git reset`, `git push`
   or anything else that changes the index or history. Format and authorship
   are in `ai-algorithms-git-commits`.
2. **Don't run notebook cells that reach Kaggle or Azure** without the user's
   OK, and never `%pip install` cells. See `ai-algorithms-notebooks`.
3. **Don't trigger workflows or releases** (`gh workflow run`, `gh run rerun`,
   `make release`). Reading runs with `gh run view --log-failed` is fine. See
   `ai-algorithms-ci`.
4. **Python 3.13 everywhere**, kept in step across the Makefile, pre-commit
   config, `pyproject.toml`, workflows and notebook kernels. Regenerate
   `requirements/*.txt` from `requirements/in/*.in` with
   `make python-requirements` rather than editing pins by hand. See
   `ai-algorithms-python-environment`.
5. **The pre-commit hooks are the lint standard.** See
   `ai-algorithms-code-quality`.
6. **This repository is public.** No Kaggle keys, Azure ids, personal paths or
   personal data in notebooks (outputs included), docs or skills. `.env`,
   `config.json`, `kaggle.json` and `jupyter/data/` are git-ignored and stay
   that way.
7. **Tooling follows azureml-example.** This repository and
   `FullStackWithLawrence/azureml-example` share a template; when their
   tooling differs for no reason, azureml-example's is the reference.

## Repository map

| Path                 | Contents                                                                    |
| -------------------- | --------------------------------------------------------------------------- |
| `jupyter/`           | The course notebooks; `jupyter/data/` holds Kaggle downloads (ignored)      |
| `docs/`              | Markdown guides (several are template leftovers; see the development skill) |
| `requirements/`      | `in/*.in` sources compiled into `base.txt` and `local.txt`                  |
| `.github/workflows/` | Lint on pull requests, semantic-release on `main`, pre-commit version bumps |
| `skills/`            | Agent Skills for developing this repository                                 |

## Common commands

```bash
make init                  # build ./venv with Python 3.13 and requirements/local.txt (deletes venv/ first)
source venv/bin/activate
make python-requirements   # recompile requirements/*.txt
make lint                  # every pre-commit hook on every file

# Lint the changed files (zsh doesn't word-split $FILES, so use xargs)
git diff --name-only | xargs pre-commit run --files
```

- `make init` deletes and rebuilds `venv/`, which is also the notebooks'
  kernel. Ask before running it.
- `make pre-commit` runs `pre-commit autoupdate`, which edits
  `.pre-commit-config.yaml`.
- `make release` makes an empty commit and pushes it. Never run it.

## Definition of done

- The change follows an existing pattern.
- Notebooks you changed still parse, and you said which cells you ran.
- Pre-commit hooks pass on the changed files.
- Nothing was pushed, released, or run against Kaggle or Azure without the
  user's say-so.
- Your summary says what changed, what you verified, and what you skipped.
