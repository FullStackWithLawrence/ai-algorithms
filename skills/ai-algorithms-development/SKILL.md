---
name: ai-algorithms-development
description: Start here for any change to the ai-algorithms repository (the Jupyter notebooks in jupyter/, the Markdown docs, the requirements, the Makefile, pre-commit, semantic-release, the GitHub workflows, commits and pull requests). Gives the non-negotiable rules, the pattern-first workflow, known oddities left over from the template the repository was made from, and an index of the narrower ai-algorithms-* skills to load for each kind of work.
---

# ai-algorithms Development

ai-algorithms is a teaching repository from Full Stack With Lawrence: Jupyter
notebooks that demonstrate basic AI algorithms in Python (anomaly detection,
regression, k-means clustering), for university courses and YouTube
tutorials. There is no Python package and no unit test suite: **the notebooks
are the product**, and everything else (requirements, Makefile, pre-commit,
semantic-release, workflows) exists to keep them runnable and versioned.

Its sister repository, `FullStackWithLawrence/azureml-example`, was made from
the same template and has been modernized first. When this repository's
tooling and azureml-example's differ for no reason, azureml-example's version
is the reference.

## Repository map

| Path                                        | What lives there                                                                            |
| ------------------------------------------- | ------------------------------------------------------------------------------------------- |
| `jupyter/*.ipynb`                           | The course notebooks. See `ai-algorithms-notebooks`                                         |
| `jupyter/data/`                             | Kaggle downloads the notebooks read. Git-ignored; never commit it                           |
| `docs/*.md`                                 | Guides. Several are Azure guides copied from azureml-example (see oddities)                 |
| `requirements/`                             | `in/*.in` sources, compiled by pip-compile into `base.txt` and `local.txt`                  |
| `Makefile`                                  | `init`, `python-requirements`, `lint`, `pre-commit`. See `ai-algorithms-python-environment` |
| `pyproject.toml`, `.flake8`, `.codespellrc` | Tool settings the pre-commit hooks read. See `ai-algorithms-code-quality`                   |
| `.pre-commit-config.yaml`                   | The lint and format standard                                                                |
| `package.json`                              | semantic-release and its plugins, Prettier                                                  |
| `commitlint.config.js`, `release.config.js` | Commit message rules and semantic-release (branches main, next, beta, alpha)                |
| `.github/workflows/`                        | Lint on pull requests, semantic-release on `main`, pre-commit version bumps, auto-assign    |
| `.github/dependabot.yml`, `.mergify.yml`    | Monthly dependency pull requests; Mergify approves and merges Dependabot's into `main`      |
| `skills/` (`.claude/skills` is a symlink)   | These Agent Skills                                                                          |

## Non-negotiable rules

1. **Never execute git write commands.** "Write a git commit" means output the
   command text. See `ai-algorithms-git-commits`.
2. **Don't run notebook cells that reach Kaggle or Azure** without the user's
   OK. `~/.kaggle/kaggle.json` is the user's real key, and
   `anomaly_detection_creditcard.ipynb` registers a model in a real Azure ML
   workspace. See `ai-algorithms-notebooks`.
3. **Python 3.13 everywhere.** The Makefile, `.pre-commit-config.yaml`,
   `pyproject.toml`, the workflows and the notebook kernels must agree. Regenerate
   `requirements/*.txt` with `make python-requirements`; never edit them by
   hand. See `ai-algorithms-python-environment`.
4. **The pre-commit hooks are the lint standard.** See
   `ai-algorithms-code-quality`.
5. **The repository is public.** No Kaggle keys, Azure subscription ids,
   personal paths or other personal data in notebooks (outputs included),
   docs, workflows or skills. `.env`, `config.json` and `kaggle.json` are
   git-ignored and stay that way.
6. **Notebooks are course material.** Edit cell by cell, keep the teaching
   voice, and don't strip or regenerate outputs a lesson relies on.
7. **Don't trigger workflows, releases or pushes.** `gh workflow run`,
   `gh run rerun`, `make release`, `git push` and anything that publishes are
   the user's to run. See `ai-algorithms-ci`.

## Pattern first

Before writing anything, find the closest existing example and copy its shape:
an existing notebook's step-by-step structure (a Markdown cell explaining each
`Step N`, then the code), an existing `.in` file's commented pins, an existing
workflow's header comment and pinned action SHAs. For tooling, check how
azureml-example does it (`/Users/mcdaniel/Desktop/gh/fswl/azureml-example`, if
it is checked out next to this one).

## Known oddities (don't copy, don't "fix" unasked)

These came from the template. Leave them alone unless the task is about them,
and don't spread them to new files. When one bites the task at hand, fix it as
its own change and say so.

- `docs/AZURE_*.md`, `docs/12-FACTOR.md` and `docs/REST_BASICS.md` are
  azureml-example and template guides; `docs/CONTRIBUTING.md` mentions
  Smarter, Docker and gulp; `.github/CONTRIBUTING.md` describes a Terraform
  and ReactJS project. None of that exists here.
- `conda.yaml` describes an `automl-env` with onnxruntime. Nothing uses it.
- `jupyter/anomaly_detection_creditcard.ipynb` uses the retired Azure ML SDK
  v1 (`azureml.core`) with a Python 3.9 kernel. It can't run in the project's
  3.13 venv. azureml-example has the maintained v2 version of this notebook.
- The README's algorithm list is out of date: k-means uses the UCI Iris data
  (not Kaggle), and `k-means-it-support-tickets.ipynb` isn't listed.
- `.github/actions/merge-branch/action.yml` is a composite action no workflow
  calls.
- The committed outputs of `k-means.ipynb`'s first cell include `pip` output
  with the maintainer's home-directory path.

## Which skill to load

| Task                                                                         | Skill                              |
| ---------------------------------------------------------------------------- | ---------------------------------- |
| Reading, editing, running or reviewing a notebook; Kaggle or Azure access    | `ai-algorithms-notebooks`          |
| The venv, Python version, requirements, Makefile targets                     | `ai-algorithms-python-environment` |
| Lint, format, pre-commit, codespell                                          | `ai-algorithms-code-quality`       |
| GitHub workflows, semantic-release, Dependabot, troubleshooting a failed run | `ai-algorithms-ci`                 |
| Writing a commit message                                                     | `ai-algorithms-git-commits`        |
| Creating or describing a pull request                                        | `ai-algorithms-pull-requests`      |

## Definition of done

- The change follows an existing pattern and reads well to a student.
- Notebooks you changed still parse (`python -m json.tool <nb> > /dev/null`),
  and any local-only cells you changed were run in the project venv, or you
  said why not.
- The pre-commit hooks pass on the changed files.
- Tooling changes are consistent across the Makefile, pre-commit, pyproject,
  the workflows and these skills.
- Nothing was pushed, released or run against Kaggle or Azure without the
  user's say-so.
- Your summary says what changed, what you verified, and what you skipped.
