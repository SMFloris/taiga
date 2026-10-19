#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
if [[ "$(git branch --show-current)" != frisbo ]]; then
    printf '%s\n' 'Switch to the frisbo branch before publishing.' >&2
    exit 1
fi
if [[ -n "$(git status --porcelain)" ]]; then
    printf '%s\n' 'Commit all changes before publishing.' >&2
    exit 1
fi

git remote get-url origin > /dev/null

# Each export has component-only history. Using commit-tree avoids a recursive
# git subtree split failure with this repository's imported upstream histories.
for component in front back; do
    git remote get-url "$component" > /dev/null
    git fetch --no-tags "$component" "frisbo:refs/remotes/$component/frisbo"
    export_ref="refs/heads/$component-frisbo"
    remote_ref="refs/remotes/$component/frisbo"
    if ! git show-ref --verify --quiet "$export_ref"; then
        git update-ref "$export_ref" "$(git rev-parse "$remote_ref")"
    fi
    if ! git merge-base --is-ancestor "$remote_ref" "$export_ref"; then
        printf 'Remote %s/frisbo has changes missing from its local export. Import and review them before publishing.\n' "$component" >&2
        exit 1
    fi
    parent=$(git rev-parse "$export_ref")
    tree=$(git rev-parse "HEAD:taiga-$component")
    if [[ "$tree" != "$(git rev-parse "$parent^{tree}")" ]]; then
        commit=$(git commit-tree "$tree" -p "$parent" \
            -m "Export taiga-$component from monorepo $(git rev-parse --short HEAD)")
        git update-ref "$export_ref" "$commit" "$parent"
    fi
done

# No force pushes. Each fork's push starts its own image publishing workflow.
git push front front-frisbo:frisbo
git push back back-frisbo:frisbo
git push origin frisbo:frisbo
