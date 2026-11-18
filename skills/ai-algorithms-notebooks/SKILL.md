---
name: ai-algorithms-notebooks
description: Use when reading, editing, adding, reviewing or running the Jupyter notebooks in ai-algorithms (jupyter/*.ipynb - anomaly_detection_creditcard, House_Prices_Regression_Demo, k-means, k-means-it-support-tickets), or when a task touches Kaggle downloads, jupyter/data/, or the Azure ML workspace a notebook uses. Covers which notebooks reach Kaggle or Azure, their kernels, editing cell by cell, outputs and what may be committed, data files, and reviewing a student's notebook pull request.
---

# Notebooks

The notebooks are course material: students read them top to bottom, often in
front of a class. Accuracy of the prose matters as much as the code.

## What's there

| Notebook                                     | Kernel                        | Data source                                                        | Reaches                           |
| -------------------------------------------- | ----------------------------- | ------------------------------------------------------------------ | --------------------------------- |
| `jupyter/k-means.ipynb`                      | `venv (3.13.x)`, project venv | UCI Iris over HTTPS (first cell also runs a Kaggle download)       | UCI, Kaggle                       |
| `jupyter/k-means-it-support-tickets.ipynb`   | `venv (3.13.x)`               | Kaggle dataset `tobiasbueck/multilingual-customer-support-tickets` | Kaggle (skips if already local)   |
| `jupyter/House_Prices_Regression_Demo.ipynb` | Google Colab (`Python 3`)     | Kaggle competition `house-prices-advanced-regression-techniques`   | Kaggle, `google.colab` uploads    |
| `jupyter/anomaly_detection_creditcard.ipynb` | `venv (3.9.6)`, a legacy venv | Azure ML data asset `creditcard_fraud`, via the v1 SDK             | Azure ML (reads, registers model) |

- The project venv (`ai-algorithms-python-environment`) has pandas,
  scikit-learn, scipy, seaborn, shap, kaggle, openpyxl and ipykernel.
- `anomaly_detection_creditcard.ipynb` imports `azureml.core` (Azure ML SDK
  v1, retired, Python < 3.12). It doesn't run in the project venv, and its
  last steps register a model in the user's workspace. Don't add `azureml-*`
  to the requirements to "fix" it; that's a rewrite to the v2 SDK, which
  azureml-example already has. Raise it with the user instead.
- `House_Prices_Regression_Demo.ipynb` runs in Colab: it calls
  `files.upload()` for `kaggle.json` and reads `jupyter/house_prices/train.csv`
  relative to Colab's working directory.
- `jupyter/data/` (house prices, support tickets) holds Kaggle downloads. It
  is git-ignored, as is `*.zip`. Kaggle's terms don't allow redistributing
  the data: never commit it.

## Rules

1. **Don't run cells that reach Kaggle or Azure** (`!kaggle ...`,
   `kaggle.api`, `Workspace`, `Dataset.get_by_name`, `Model.register`,
   `files.upload()`) without the user's OK. `~/.kaggle/kaggle.json` is the
   user's real key; Kaggle downloads are rate limited, and competitions need
   their rules accepted on kaggle.com first. `Model.register` writes to a real,
   paid Azure workspace. Local pandas, scikit-learn, matplotlib and shap cells
   are fine to run in the matching kernel, once the data is on disk.
2. **Don't run `%pip install` cells.** They change the user's venv outside the
   requirements files. Install from `requirements/local.txt` instead.
3. **Edit cell by cell** with the notebook editing tool. Don't rewrite or
   re-serialize a whole notebook: it churns metadata and makes the diff
   unreadable. The tool itself causes churn: it saves an edited cell's
   `source` as one string instead of a list of lines, and clears an edited
   code cell's `outputs` and `execution_count`. After editing, normalize every
   cell's `source` back to a list of lines (`str.splitlines(keepends=True)`)
   and write the notebook with `json.dumps(nb, indent=1, ensure_ascii=False)`
   plus a trailing newline. Then check that `git diff` shows only the real
   changes. Edit kernel metadata as a text replacement in the file.
4. **Outputs.** The two k-means notebooks are committed with outputs (plots a
   lesson shows); the other two without. Keep each as it is unless asked.
   Before any notebook is committed, check its outputs for anything personal:
   home-directory paths (`/Users/<name>/...`, as in `k-means.ipynb`'s pip
   output today), Kaggle usernames, Azure subscription or workspace details.
5. **Keep the teaching voice.** Markdown cells explain why, step by step
   (`## Step N: ...`). Correct wrong statements (metrics, what a plot shows,
   which dataset is used), but don't flatten the explanations into terse
   comments.
6. **No secrets in cells.** Credentials come from `~/.kaggle/kaggle.json`,
   `config.json` or `.env`, never literals. Placeholders look like
   `[REPLACE-THIS-WITH-YOUR-USERNAME]`.
7. **Kernels match the venv.** A notebook meant for the project venv names
   `venv (3.13.x)` in its kernelspec. When the Python version changes, update
   the kernel display names too.

## Checking a notebook without running it

```bash
python -m json.tool jupyter/<name>.ipynb > /dev/null    # it parses
git diff --stat jupyter/                                 # only the cells you meant
```

pre-commit's `check-json` also parses notebooks. codespell skips `jupyter/`
(`.pre-commit-config.yaml`), and black and isort don't touch `.ipynb`.

## Reviewing a student's notebook pull request

Check that it runs in its stated kernel (by reading it, or running local-only
cells), that the prose matches the code and the results, that no outputs leak
anything (rule 4), that no data files, zips or generated HTML were added, and
that it's in `jupyter/`. Report findings; don't push changes to their branch.
