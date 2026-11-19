# Contributing to Claude-Backup

Thanks for helping. Claude-Backup is small: two installers and four `SKILL.md` files that Claude reads. Most
contributions are either an installer fix (bash or PowerShell) or a change to how the backup task or a skill behaves
(markdown instructions). Reports from Windows and Linux users are especially welcome.

Please read the [Code of Conduct](https://github.com/abhinav-adtechs/.github/blob/main/CODE_OF_CONDUCT.md) before
taking part, and report security problems through the
[security policy](https://github.com/abhinav-adtechs/.github/blob/main/SECURITY.md) rather than a public issue.

## What's where

| Path                       | What it is                                      | Change it when…                                          |
| -------------------------- | ----------------------------------------------- | -------------------------------------------------------- |
| `install.sh`               | macOS and Linux installer                       | Install paths, flags, OS detection                       |
| `install.ps1`              | Windows installer                               | Same, for Windows; keep the two in step                  |
| `scheduled-task/SKILL.md`  | The `session-backup` Cowork task                | What gets backed up, the vault layout, incremental logic |
| `skill/SKILL.md`           | `vault-resume`                                  | How a new session loads context                          |
| `skill-search/SKILL.md`    | `vault-search` (optional)                       | How the vault is searched                                |
| `skill-verify/SKILL.md`    | `vault-verify` (optional)                       | The health report                                        |
| `vault-gitignore.template` | Copied to `<vault>/.gitignore` on first install | What stays out of a synced vault                         |

## Development setup

You need `git` and `bash`. To work on `install.ps1`, PowerShell 7 (`pwsh`) on any OS, and ideally Windows PowerShell
5.1 on Windows too, since the installer targets both. To try the backup task and the skills end to end, Claude
Desktop with Cowork.

```bash
git clone https://github.com/abhinav-adtechs/Claude-Backup.git
cd Claude-Backup
```

### Test the installers without touching your real setup

Both installers write under your home folder, so point it somewhere disposable first. This is exactly what CI runs on
macOS and Ubuntu:

```bash
export HOME="$(mktemp -d)"            # only for this shell
VAULT="$HOME/My Vault"
bash -n install.sh
bash ./install.sh "$VAULT"
bash ./install.sh --check
grep -q "$VAULT/" "$HOME/.claude/vault-resume/SKILL.md" && echo "vault path substituted"
bash ./install.sh --uninstall
test -f "$VAULT/.gitignore" && echo "vault kept"
```

On Windows (or with `pwsh` anywhere), the same idea in a new PowerShell window:

```powershell
$env:USERPROFILE = Join-Path ([System.IO.Path]::GetTempPath()) "cb-home"   # only for this window
.\install.ps1 -VaultPath (Join-Path $env:USERPROFILE "My Vault")
.\install.ps1 -Check
.\install.ps1 -Uninstall
```

CI runs this same scenario on `windows-latest` in both Windows PowerShell 5.1 and PowerShell 7 (the `install-ps1`
job in `.github/workflows/ci.yml`). It also checks that both installed `SKILL.md` files start with `---` (no BOM) and
that the vault's `.gitignore` is still there after uninstalling.

### Test a change to the backup task or a skill

1. Install into a test vault, for example `./install.sh ~/ClaudeVault-test`. This replaces the installed task and
   resume skill with your working copy, pointed at the test vault.
2. In Cowork, **Scheduled** › **Run now** on `session-backup`, and check `_backup-log.md`, `_index.md` and a project's
   `_project-summary.md` in the test vault.
3. In a new session, ask _"pick up where I left off"_ and check that the resume skill reads the right files.
4. When you're done, install again with your real vault path.

## Conventions

- **Keep the placeholder path exact.** The installers replace the literal string `~/Documents/ClaudeVault/` (with the
  trailing slash) in the task and the resume skill. Write the vault path that way in any new instruction, or it won't
  follow a custom vault location.
- **Keep the installers in step.** A new flag in `install.sh` needs the matching parameter in `install.ps1`, the
  README's Configuration table, and the `--check` output on both.
- **Keep `install.ps1` ASCII-only** so Windows PowerShell 5.1 parses it whatever the system code page.
- **Never delete vault data.** `--uninstall` / `-Uninstall` remove only what the installer put in place; the backup task
  only adds or updates.
- **No personal data in examples.** Use placeholders like `/Users/alice/WebKitchen/my-app` and `my-web-app` in
  skills, docs and tests.
- **Skills stay scoped.** `vault-resume` loads one project when it knows which; keep new instructions from reading the
  whole vault by default.

## Branches and commits

- Branch from `main`: `feat/<short-name>`, `fix/<short-name>`, `docs/<short-name>`.
- Use [Conventional Commits](https://www.conventionalcommits.org/), with a scope where it helps:
  `fix(install.ps1): …`, `feat(task): …`, `feat(resume): …`, `docs: …`, `ci: …`.
- Subject in the imperative, under 72 characters; the body says why.

## Filing issues

- **Installer problems:** your OS and version, the shell (`bash --version` or `$PSVersionTable.PSVersion`), the exact
  command, and its full output, plus `./install.sh --check` or `.\install.ps1 -Check`.
- **Backup problems:** the latest entries of `_backup-log.md` and what's missing from the vault. **Redact** anything
  from transcripts or settings before you paste it.
- **Ideas:** what you were trying to recover or resume, and what the vault didn't give you.

## Pull request checklist

- [ ] `bash -n install.sh` passes, and the throwaway-home test above passes
- [ ] If you changed `install.ps1`: tested with `pwsh` (and Windows PowerShell 5.1 if you can), and it is still ASCII-only
- [ ] If you changed a `SKILL.md`: ran it against a test vault, and the vault path still uses `~/Documents/ClaudeVault/`
- [ ] Both installers and the README agree on flags, paths and defaults
- [ ] `CHANGELOG.md` has a line under **Unreleased**
- [ ] No personal paths, transcripts, keys or tokens in the diff
