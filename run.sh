#!/usr/bin/env bash

# Does not handle pagination. Need to update the script if we have more than 100
# repos.
LIST_OF_REPOS="$(
    # shellcheck disable=SC2154
    curl -sSLf \
        -H 'Accept: application/vnd.github+json' \
        -H "Authorization: Bearer ${GITHUB_TOKEN}" \
        -H 'X-GitHub-Api-Version: 2026-03-10' \
        'https://api.github.com/orgs/northwood-labs/repos?per_page=100&page=1'
)"

# Filtered to remove private repos and sorted alphabetically.
LIST_OF_REPOS="$(
    echo "${LIST_OF_REPOS}" \
      | jq -Mr '
        [
          .[]
          | select(.private == false)
          | select(
              .name
              | startswith(".")
              | not
            )
          | .name
        ]
        | sort
        | .[]
      ' \
      || true
)"


while IFS= read -r repo; do
    mkdir -p "docs/${repo}"
    cat << EOF > "docs/${repo}/index.html"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="go-import" content="/${repo} git https://github.com/northwood-labs/${repo}">
    <meta http-equiv="refresh" content="0;URL='https://github.com/northwood-labs/${repo}'">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${repo}</title>
</head>
<body>
    <h1>${repo}</h1>
    <p>Redirecting you to the <a href="https://github.com/northwood-labs/${repo}">northwood-labs/${repo}</a> project page...</p>
</body>
</html>
EOF
done <<< "${LIST_OF_REPOS}"
