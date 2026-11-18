---
name: ai-algorithms-python-environment
description: Use when ai-algorithms' notebooks or tools must run locally, when the virtual environment is missing or broken (e.g. ModuleNotFoundError in a notebook kernel), or when changing the Python version, requirements (requirements/in/*.in and the compiled requirements/*.txt), Dependabot's pip updates, or Makefile targets. Covers the Python 3.13 target, the venv folder that is also the notebooks' kernel, compiling requirements with pip-compile, and the Makefile's destructive targets.
---

# Python Environment

## Python 3.13

The repository runs on Python 3.13: `PYTHON := python3.13` in the Makefile,
`default_language_version: python: python3.13` in `.pre-commit-config.yaml`,
`requires-python = ">=3.13"` and black's `py313` in `pyproject.toml`,
`python-version: "3.13"` in the workflows, and `venv (3.13.x)` in the notebook
kernels. Change them together, or not at all. (azureml-example has moved to
3.14; moving this repository too is a deliberate change of its own, after
checking that every package in `base.in` has 3.14 wheels.)

Before adding any package, check PyPI's `requires_python` and wheels for 3.13
(`curl -s https://pypi.org/pypi/<name>/json`).

## The folders on disk

| Folder          | What it is                                                                                                               |
| --------------- | ------------------------------------------------------------------------------------------------------------------------ |
| `venv/`         | The project venv from `make init`: Python 3.13 + `requirements/local.txt`. It is also the Jupyter kernel `venv (3.13.x)` |
| `node_modules/` | semantic-release, Prettier (from `npm install`)                                                                          |

If `venv/` is missing or broken, don't rebuild it with `make init` unasked
(see below). `pip install -r requirements/local.txt` into the existing venv is
fine. Report which environment you actually ran in.

## Requirements files

The `.txt` files are compiled from `requirements/in/*.in` with pip-compile
(from `pip-tools`, in `local.in`), on Python 3.13.

| File                                 | Contents                                                                                                          |
| ------------------------------------ | ----------------------------------------------------------------------------------------------------------------- |
| `requirements/in/constraints.in`     | Global version constraints, included by every `.in` file. None today                                              |
| `requirements/in/base.in`            | What the notebooks import: pandas, scikit-learn, scipy, seaborn, shap, kaggle, openpyxl, ipykernel, python-dotenv |
| `requirements/in/local.in`           | `base.in` + pip-tools, pre-commit and the linters                                                                 |
| `requirements/base.txt`, `local.txt` | The compiled, fully pinned output. Don't edit by hand. `make init` installs `local.txt`                           |

- `.in` files never carry version pins (`==`): list the bare package with a
  short trailing comment saying what it is for, and let pip-compile pin it.
  A range goes in `constraints.in` only for a known incompatibility, with a
  comment naming the package that needs it. Then recompile with `make python-requirements`, or by hand
  `pip-compile --strip-extras requirements/in/base.in -o requirements/base.txt`
  (and `local`). Add `--upgrade` only when upgrading is the task. When an old
  pin in a `.txt` file blocks the resolve, upgrade just that package
  (`pip-compile -P <name> ...`) rather than pinning in a `.in` file.
- A package a notebook imports goes in `base.in`; a dev tool in `local.in`.
- Dependabot watches `requirements/` (the compiled `.txt` files), so its pull
  requests change real pins.
- `release.config.js` commits `requirements/**/*` on release; don't fight it.

## Makefile

| Target                     | Effect                                                                                    |
| -------------------------- | ----------------------------------------------------------------------------------------- |
| `make` (any target)        | Creates `.env` from `.env.example` if it's missing                                        |
| `make init`, `python-init` | **`python-init` runs `python-clean` first: deletes `venv/`**. Ask first                   |
| `make python-requirements` | Compiles `base.in` and `local.in` into `requirements/*.txt`                               |
| `make lint`                | Runs every pre-commit hook on every file                                                  |
| `make pre-commit`          | `pre-commit install`, **`pre-commit autoupdate`** (edits the config), then runs the hooks |
| `make analyze`             | `cloc` report                                                                             |
| `make release`             | Pushes an empty commit to force a release. Never run it                                   |

The host shell is zsh. It doesn't word-split variables, so pass file lists with
`xargs` or an array, not `$FILES`.
