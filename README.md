# Taiga monorepo

Workspace for changes spanning the Taiga frontend and backend.

| Directory | Source fork | Imported revision | Version |
| --- | --- | --- | --- |
| `taiga-front/` | [SMFloris/taiga-front](https://github.com/SMFloris/taiga-front) | `367a4b850f088922359fadea1e5ffe0ff36f0b3b` (`main`) | 6.10.3 |
| `taiga-back/` | [SMFloris/taiga-back](https://github.com/SMFloris/taiga-back) | `c8264ac6775103cbcc2a3a145978f2b475e9ff05` (`main`) | 6.10.2 |

Both projects are normal directories in one Git repository, imported with Git subtrees and their full commit histories. Changes to the API and UI can share a commit.

The original notes are in [docs/WISHLIST.md](docs/WISHLIST.md). See [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) for development and fork maintenance. Run `make help` for shortcuts.

## Finish Git initialization

This workspace was prepared in an agent session that mounted its `.git` directory read-only. The source files are ready to edit; the complete repository history is in `.bootstrap/taiga.bundle`.

Run this once from a terminal with write access to `.git`:

```sh
./scripts/initialize-git.sh
```

The script imports the prepared history, preserves working files, and configures the two fork remotes and two upstream remotes. No monorepo `origin` is configured yet. Keep `.bootstrap/taiga.bundle` until initialization succeeds.

## Licensing

The frontend retains its [AGPLv3 license](taiga-front/LICENSE); the backend retains its [MPL 2.0 license](taiga-back/LICENSE). Their existing license notices remain in place.
