# ai-algorithms Agent Skills

This folder holds the [Agent Skills](https://agentskills.io/specification) for
working on this repository with an AI coding agent such as Claude Code. This
README is for people; the `SKILL.md` files are for the agent.

A skill is a folder of written know-how that an agent loads only when a task
needs it. Each contains a `SKILL.md`, with a `name` and a `description` in its
front matter that tell the agent when to load it. They are developer tooling,
like the `Makefile` and `.pre-commit-config.yaml`; no code here loads them.

## What's here

Start with `ai-algorithms-development`. It sets the rules for every change, and
its table says which narrower skill to load.

| Skill                              | Use it when                                                          |
| ---------------------------------- | -------------------------------------------------------------------- |
| `ai-algorithms-development`        | You're making any change. Start here.                                |
| `ai-algorithms-notebooks`          | You're editing, running or reviewing a notebook, or touching Kaggle. |
| `ai-algorithms-python-environment` | The venv, Python 3.13, requirements or make targets.                 |
| `ai-algorithms-code-quality`       | You're finishing a change and need the pre-commit hooks.             |
| `ai-algorithms-ci`                 | Workflows, semantic-release, Dependabot, or a failed run.            |
| `ai-algorithms-git-commits`        | You've been asked to write a commit message.                         |
| `ai-algorithms-pull-requests`      | You're creating or describing a pull request.                        |

The repository's [CLAUDE.md](../CLAUDE.md) holds the few rules that apply to
nearly every task, and points here for the rest.

## How agents find them

Claude Code reads project skills from `.claude/skills/`, which is a committed
symlink to this folder. It loads each skill's description at the start of a
session and the body when a task matches; you can also call one directly, e.g.
`/ai-algorithms-git-commits`. If the symlink breaks (e.g. a Windows checkout
without symlink support), Claude Code silently stops seeing the skills.

Other agents that support the Agent Skills format read `SKILL.md` folders from
their own configuration location. Agents without skill support can be told to
read `skills/ai-algorithms-development/SKILL.md` at the start of a session.

## Security considerations

A skill is a set of instructions an agent follows, often without asking.
**Review a change to this folder with the same care as a change to CI.**

- **The local environment holds live credentials.** `~/.kaggle/kaggle.json`
  is a real Kaggle key, and one notebook reaches a paid Azure ML workspace.
  `ai-algorithms-notebooks` exists so that an agent doesn't run those cells
  on its own. Don't weaken it.
- **A rule applies to every task that triggers the skill.** State limits
  rather than absolutes that become harmful in some case.
- **Broad descriptions have a wide reach.** A skill meant for notebooks that
  says "use when changing Python" will load, and be followed, for unrelated
  work.
- **Some rules forbid things on purpose.** `ai-algorithms-git-commits` tells
  the agent never to run `git commit`, `git add` or `git push`, and
  `ai-algorithms-ci` never to trigger workflows or releases. Don't remove that
  unless you mean to give agents that power.
- **Watch for prompt injection.** Look for instructions unrelated to a skill's
  purpose, new scripts or network calls, text that tells the agent to skip
  confirmations or hooks, and links it is told to fetch and follow.
- **Stale skills mislead.** When a convention changes (a make target, the
  Python version, a workflow), update the skill in the same pull request.
- **Keep secrets out.** This repository is public. Use placeholders, and tell
  the agent where to find the real value at run time.
