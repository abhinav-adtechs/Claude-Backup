# Changelog

All notable changes to Claude-Backup are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Fixed

- `install.sh` and `install.ps1` now resolve their source files relative to the installer itself, so they work from any directory; a missing source file now stops the install with an error instead of silently writing an empty `SKILL.md`.

### Added

- A rewritten README with per-OS install instructions, an architecture diagram and a configuration reference.
- `CONTRIBUTING.md`, this changelog and `docs/ARCHITECTURE.md`.
- CI: an `install.sh` smoke test on macOS and Ubuntu that installs into a throwaway home with a custom vault path,
  checks the path substitution, and uninstalls without touching the vault.

## [1.2.0] - 2026-04-13

### Added

- `install.ps1`, a Windows installer with `-VaultPath`, `-Check` and `-Uninstall`.
- `install.sh`: OS detection with Linux defaults (`~/.local/share/ClaudeVault`), `--check` and `--uninstall`, and a
  check that both files were written.
- `vault-search`, a skill that searches plans, summaries, history and transcripts across the whole vault.
- `vault-verify`, a skill that reports the last backup time, missing files and incomplete projects.
- `vault-gitignore.template`, installed as the vault's `.gitignore` on first install, keeping transcripts, file
  history and shell snapshots out of any repo the vault is synced to.
- Backup task: an `IN PROGRESS` marker at the start of each run, incremental backups using `.timestamps.json`, and
  OS-aware `stat` commands.
- Resume skill: a scoping rule that loads only the named (or current working directory's) project, and a warning when
  the last successful backup is more than 24 hours old.
- README: Windows install, Security, Troubleshooting and how path encoding works.

### Changed

- The resume skill's examples use generic placeholders.

### Fixed

- Project directories under `~/.claude/projects/` are decoded with a path map built from `history.jsonl` instead of
  guessing where dashes were slashes.

## [1.1.0] - 2026-04-13

### Added

- A custom vault location: `./install.sh /path/to/vault`.
- Every conversation transcript in `~/.claude/projects/` (Code, Cowork and Desktop) is backed up and converted from
  JSONL to readable markdown.
- Plans are renamed from their random codenames to descriptive titles from their heading, with a `plans/_index.md` per
  project; the resume skill can list, show and resume plans.

## [1.0.0] - 2026-04-13

### Added

- The `session-backup` Cowork scheduled task: plans, prompt history, session metadata, file edit history, global
  config, settings, plugins, Cowork transcripts and shell snapshots, organised by project in
  `~/Documents/ClaudeVault/` with per-project summaries and a master index.
- The `vault-resume` skill, so a new session on any account can pick up where you left off.
- `install.sh`, which installs both.
- MIT license.

### Changed

- The repository is named Claude-Backup; the README's clone URL matches.

[Unreleased]: https://github.com/abhinav-adtechs/Claude-Backup/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/abhinav-adtechs/Claude-Backup/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/abhinav-adtechs/Claude-Backup/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/abhinav-adtechs/Claude-Backup/commits/v1.0.0
