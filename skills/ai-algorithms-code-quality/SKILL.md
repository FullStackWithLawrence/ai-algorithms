---
name: ai-algorithms-code-quality
description: Use before finishing any ai-algorithms change, to lint and format Markdown, JSON, YAML, notebooks and any Python with the repository's pre-commit hooks (pyupgrade, codespell, Prettier, black, flake8, isort, autoflake, bandit, pre-commit-hooks, commitlint), or when changing .pre-commit-config.yaml, pyproject.toml, .flake8, .codespellrc or codespell.txt. Explains what each hook enforces, how to run the hooks on changed files under zsh, and the style conventions.
---

# Code Quality

`.pre-commit-config.yaml` is the standard. If a hook passes, the change meets
it; if it fails, fix the change. Never bypass a hook (`--no-verify`, `SKIP=`, a
blanket `# noqa`).

## What the hooks enforce

| Hook             | Configuration                                  | Notes                                                                                                                        |
| ---------------- | ---------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| pyupgrade        | default                                        | Python files only (there are none today)                                                                                     |
| codespell        | `.codespellrc`, `--ignore-words=codespell.txt` | Skips `requirements/` and `jupyter/`. Add real project words to `codespell.txt`                                              |
| prettier         | `.prettierrc.json`, `.prettierignore`          | Markdown, JSON, YAML. Let it reformat                                                                                        |
| black            | `pyproject.toml`, line length 120, `py313`     | Formatter                                                                                                                    |
| flake8           | `.flake8`                                      | `select = C101` only (coding magic comment)                                                                                  |
| isort            | `pyproject.toml` (`profile = black`)           | The hook passes `--settings-path=pyproject.toml`, so that file must exist                                                    |
| autoflake        | `--remove-all-unused-imports`                  |                                                                                                                              |
| bandit           | `-ll`                                          | Medium and high findings fail                                                                                                |
| pre-commit-hooks | v6                                             | JSON (notebooks too)/TOML/XML/YAML syntax, merge markers, symlinks, private keys, AWS keys, trailing whitespace, end-of-file |
| commitlint       | `commitlint.config.js`, commit-msg stage       | See `ai-algorithms-git-commits`                                                                                              |

`default_install_hook_types: [pre-commit, commit-msg]` makes `pre-commit
install` install the commitlint hook too.

## How to run

```bash
source venv/bin/activate
git diff --name-only | xargs pre-commit run --files
git ls-files --others --exclude-standard | xargs pre-commit run --files   # new files
```

- Use `xargs`: under zsh `pre-commit run --files $FILES` passes one argument
  and checks nothing.
- Hooks that rewrite files (black, isort, Prettier, end-of-file-fixer) fail
  the first run and pass the second. Run twice, and read the diff.
- `--all-files` skips untracked files.
- `make pre-commit` runs `pre-commit autoupdate`, which edits
  `.pre-commit-config.yaml`. Don't run it as part of another change; the
  weekly `precommitVersionBumps.yml` workflow does it.
- The hooks bring their own environments, but the Python ones need a
  `python3.13` on the PATH.

## Changing the hook configuration

- Keep it in step with azureml-example's `.pre-commit-config.yaml`, apart from
  the Python version and the `exclude` paths that fit this repository.
- A hook that references a settings file (isort's `--settings-path`) needs
  that file committed, or it fails on every run.
- Every tool a hook needs in CI must be installable from
  `requirements/local.txt` (`pre-commit` itself is pinned there).

## Style

- Simple over compact: about one operation per line. Students read this code
  line by line.
- Markdown docs: weave new material into the guide it belongs to rather than
  adding a "what's new" section.
- Comments explain what a student wouldn't guess, not what the next line does.
- Don't reformat files you didn't change.
