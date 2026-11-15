#!/usr/bin/env bash
# Syncs this repository and one of its releases to the public GitHub repository.
#
# Forgejo is the source of truth. GitHub gets the branch and the tags that exist
# here, plus the release as a GitHub release object, because the Home Assistant
# Marketplace reads a release and a tag alone is not one. Nothing is ever
# deleted on GitHub, and a tag that is published there never moves: the download
# the Marketplace points at hangs off that tag.
set -euo pipefail

cd "$(dirname "$0")/.."

: "${GH_RELEASE_TOKEN:?GH_RELEASE_TOKEN is required}"
: "${FORGEJO_TOKEN:?FORGEJO_TOKEN is required}"
: "${FORGEJO_API_URL:?FORGEJO_API_URL is required}"
: "${FORGEJO_REPOSITORY:?FORGEJO_REPOSITORY is required}"
: "${GITHUB_DISTRIBUTION_REPOSITORY:?GITHUB_DISTRIBUTION_REPOSITORY is required}"

branch=${BRANCH:-main}
release_tag=${RELEASE_TAG:-}
github_url="https://github.com/${GITHUB_DISTRIBUTION_REPOSITORY}.git"
github_api="https://api.github.com/repos/${GITHUB_DISTRIBUTION_REPOSITORY}"

# The token goes into a header and never into the remote url: git repeats the
# url in its error messages and would repeat the password with it.
auth_header="Authorization: Basic $(printf 'x-access-token:%s' "$GH_RELEASE_TOKEN" | base64 -w0)"
github() { git -c "http.extraHeader=${auth_header}" "$@"; }

json() {
  node -e '
    let input = "";
    process.stdin.on("data", (chunk) => (input += chunk)).on("end", () => {
      let value = JSON.parse(input);
      for (const key of process.argv.slice(1)) value = value[key];
      process.stdout.write(value === undefined || value === null ? "" : String(value));
    });
  ' "$@"
}

git fetch --quiet --tags origin

echo '::group::Branch'
if git rev-parse --verify --quiet "refs/heads/${branch}" >/dev/null; then
  source_ref="refs/heads/${branch}"
else
  source_ref="refs/remotes/origin/${branch}"
fi
test -n "$(git rev-parse --verify --quiet "$source_ref")" || {
  echo "No ${branch} in this checkout to push" >&2
  exit 1
}
github push --quiet --force "$github_url" "${source_ref}:refs/heads/${branch}"
echo "Pushed ${source_ref} to ${branch}."
echo '::endgroup::'

echo '::group::Tags'
tags=$(git tag --list)
if test -z "$tags"; then
  echo "No tags here, nothing to push."
else
  # The peeled commit of every tag on GitHub, named refs/tags/<tag> for both tag types.
  remote_tags=$(github ls-remote --tags "$github_url" | awk '
    {
      peeled = ($2 ~ /\^\{\}$/)
      name = $2
      sub(/\^\{\}$/, "", name)
      if (peeled || !(name in sha)) sha[name] = $1
    }
    END { for (name in sha) print name, sha[name] }
  ')
  refspecs=()
  moved=""
  present=0
  while read -r tag; do
    test -n "$tag" || continue
    local_sha=$(git rev-parse "refs/tags/${tag}^{commit}")
    remote_sha=$(printf '%s\n' "$remote_tags" | awk -v name="refs/tags/${tag}" '$1 == name { print $2 }')
    if test -z "$remote_sha"; then
      refspecs+=("refs/tags/${tag}:refs/tags/${tag}")
    elif test "$remote_sha" = "$local_sha"; then
      present=$((present + 1))
    else
      moved="${moved} ${tag} (GitHub $(printf '%.7s' "$remote_sha") would become $(printf '%.7s' "$local_sha"))"
    fi
  done <<<"$tags"
  if test -n "$moved"; then
    echo "A published tag never moves: it is the version the Marketplace hands out," >&2
    echo "and its GitHub release hangs off it." >&2
    echo "Moved here:${moved}" >&2
    exit 1
  fi
  if test "${#refspecs[@]}" = 0; then
    echo "All ${present} tag(s) are already on GitHub."
  else
    github push --quiet "$github_url" "${refspecs[@]}"
    echo "Pushed ${#refspecs[@]} new tag(s), ${present} already there."
  fi
fi
echo '::endgroup::'

if test -z "$release_tag"; then
  echo "No release tag given, so no release was published. Refs are up to date."
  exit 0
fi

echo '::group::Release'
release=$(curl -fsS -H "Authorization: token ${FORGEJO_TOKEN}" \
  "${FORGEJO_API_URL}/repos/${FORGEJO_REPOSITORY}/releases/tags/${release_tag}") || {
  echo "Forgejo has no release for ${release_tag}" >&2
  exit 1
}

tag_commit=$(git rev-parse --verify --quiet "refs/tags/${release_tag}^{commit}" || true)
if test -z "$tag_commit"; then
  tag_commit=$(printf '%s' "$release" | json target_commitish)
fi

payload=$(printf '%s' "$release" | GITHUB_TARGET_COMMIT="$tag_commit" node -e '
  let input = "";
  process.stdin.on("data", (chunk) => (input += chunk)).on("end", () => {
    const release = JSON.parse(input);
    process.stdout.write(JSON.stringify({
      tag_name: release.tag_name,
      name: release.name || release.tag_name,
      body: release.body || "",
      draft: false,
      prerelease: release.prerelease === true,
      target_commitish: process.env.GITHUB_TARGET_COMMIT,
    }));
  });
')

release_file=$(mktemp)
status=$(curl -sS -o "$release_file" -w '%{http_code}' \
  -H "Authorization: Bearer ${GH_RELEASE_TOKEN}" -H "Accept: application/vnd.github+json" \
  "${github_api}/releases/tags/${release_tag}")

if test "$status" = "404"; then
  method=POST
  url="${github_api}/releases"
elif test "$status" = "200"; then
  method=PATCH
  url="${github_api}/releases/$(json id <"$release_file")"
else
  echo "GitHub answered ${status} on the release of ${release_tag}" >&2
  cat "$release_file" >&2
  rm -f "$release_file"
  exit 1
fi
rm -f "$release_file"

created=$(curl -fsS -X "$method" "$url" \
  -H "Authorization: Bearer ${GH_RELEASE_TOKEN}" -H "Accept: application/vnd.github+json" \
  -H "Content-Type: application/json" -d "$payload")

html_url=$(printf '%s' "$created" | json html_url)
echo "${method} ${url}"
echo "Release ${release_tag} on GitHub: ${html_url}"
if test -n "${GITHUB_STEP_SUMMARY:-}"; then
  {
    printf '%s\n\n' "**${release_tag}** is on [${GITHUB_DISTRIBUTION_REPOSITORY}](${html_url})."
    printf '%s\n' "$(printf '%s' "$created" | json body)"
  } >>"$GITHUB_STEP_SUMMARY"
fi
echo '::endgroup::'
