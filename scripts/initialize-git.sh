#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$repo_dir"
bundle="$repo_dir/.bootstrap/taiga.bundle"

if [[ -e .git/HEAD || -f .git ]]; then
    printf '%s\n' 'This directory already has Git metadata; leaving it unchanged.' >&2
    exit 1
fi
if [[ ! -f "$bundle" ]]; then
    printf '%s\n' "Missing history bundle: $bundle" >&2
    exit 1
fi

# Reset only the index; retain source edits made before initialization.
git init -b main
git bundle verify "$bundle"
git fetch "$bundle" \
    refs/heads/main:refs/remotes/bootstrap/main \
    refs/remotes/front/main:refs/remotes/front/main \
    refs/remotes/back/main:refs/remotes/back/main
git reset --mixed refs/remotes/bootstrap/main
git update-ref -d refs/remotes/bootstrap/main
git remote add front https://github.com/SMFloris/taiga-front.git
git remote add back https://github.com/SMFloris/taiga-back.git
git remote add upstream-front https://github.com/taigaio/taiga-front.git
git remote add upstream-back https://github.com/taigaio/taiga-back.git
git status --short --branch
printf '%s\n' 'Monorepo initialized. Both component histories are available.'
