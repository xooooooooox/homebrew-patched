#!/usr/bin/env bash
# Bump a patched formula to a new fork tag.
#
# Usage: bump-formula.sh <formula> <tag>
#   <formula>  formula name, e.g. "yadm" (expects Formula/<formula>.rb)
#   <tag>      fork tag, e.g. "3.5.0-patched.1"
#
# Conventions this script relies on (see README):
#   - formula url points at a github.com/<owner>/<tool> tag tarball
#   - tags are named <upstream-version>-patched.<n>
#   - formula declares explicit `version` and `revision` lines
set -euo pipefail

formula="${1:?usage: bump-formula.sh <formula> <tag>}"
tag="${2:?usage: bump-formula.sh <formula> <tag>}"
file="Formula/${formula}.rb"

[[ -f "$file" ]] || { echo "error: $file not found" >&2; exit 1; }

# Parse <upstream-version> and <n> out of "<upstream-version>-patched.<n>"
if [[ ! "$tag" =~ ^(.+)-patched\.([0-9]+)$ ]]; then
    echo "error: tag '$tag' does not match '<upstream-version>-patched.<n>'" >&2
    exit 1
fi
version="${BASH_REMATCH[1]}"
rev="${BASH_REMATCH[2]}"

# Derive the new url from the existing one (replace the tag segment)
old_url=$(sed -n 's/^ *url "\(.*\)"$/\1/p' "$file")
[[ -n "$old_url" ]] || { echo "error: no url line found in $file" >&2; exit 1; }
new_url=$(echo "$old_url" | sed "s|/tags/[^/]*\.tar\.gz$|/tags/${tag}.tar.gz|")

# Compute sha256 of the new tarball
echo "fetching $new_url ..."
sha=$(curl -fsL "$new_url" | shasum -a 256 | cut -d' ' -f1)
[[ -n "$sha" ]] || { echo "error: failed to compute sha256" >&2; exit 1; }

# Update url / sha256 / version / revision in place
sed -i.bak \
    -e "s|^\( *\)url \".*\"$|\1url \"${new_url}\"|" \
    -e "s|^\( *\)sha256 \".*\"$|\1sha256 \"${sha}\"|" \
    -e "s|^\( *\)version \".*\"$|\1version \"${version}\"|" \
    -e "s|^\( *\)revision .*$|\1revision ${rev}|" \
    "$file"
rm -f "${file}.bak"

echo "bumped $file:"
grep -E '^\s*(url|sha256|version|revision)' "$file"
