#!/usr/bin/env bash
# Shared helpers for report-specific repository exclusions.

load_report_exclusions() {
  local file="$1"
  local key="$2"

  report_excluded_repos=()

  [ -f "$file" ] || {
    echo "Report exclusions file not found: $file" >&2
    exit 1
  }

  jq -e --arg key "$key" '
    def valid_exclusion_list:
      type == "array" and
      all(.[];
        type == "object" and
        (.repo | type == "string" and length > 0) and
        ((has("reason") | not) or (.reason | type == "string")) and
        ((keys_unsorted - ["repo", "reason"]) | length == 0)
      ) and
      ((map(.repo) | length) == (map(.repo) | unique | length));

    . as $root |
    type == "object" and
    ((keys_unsorted - ["openssf_scorecard", "reuse", "sca_renovate", "codeowners"]) | length == 0) and
    has($key) and
    all(keys_unsorted[]; . as $entry_key | ($root[$entry_key] | valid_exclusion_list))
  ' "$file" >/dev/null || {
    echo "Invalid report exclusions for key '$key': $file" >&2
    exit 1
  }

  mapfile -t report_excluded_repos < <(jq -r --arg key "$key" '.[ $key ] // [] | .[].repo' "$file")
}

validate_report_exclusions_repositories() {
  local repositories="$1"
  local org="$2"
  local missing

  [ "${#report_excluded_repos[@]}" -gt 0 ] || return 0

  [ -f "$repositories" ] || {
    echo "Repository list not found: $repositories" >&2
    exit 1
  }

  missing="$(printf '%s\n' "${report_excluded_repos[@]}" | jq -r -R -s --slurpfile repositories "$repositories" --arg org "$org" '
    split("\n")[:-1] as $excluded |
    ($repositories[0].repositories // [] | map(select(.org == $org) | .repo)) as $known |
    $excluded | map(. as $repo | select(($known | index($repo)) | not)) | .[]
  ')"

  if [ -n "$missing" ]; then
    echo "Report exclusions contain unknown repositories for $org:" >&2
    printf '%s\n' "$missing" >&2
    exit 1
  fi
}

is_report_excluded() {
  local needle="$1"
  local repo

  for repo in "${report_excluded_repos[@]}"; do
    [ "$repo" = "$needle" ] && return 0
  done

  return 1
}

report_excluded_repos_json() {
  if [ "${#report_excluded_repos[@]}" -eq 0 ]; then
    printf '[]\n'
  else
    printf '%s\n' "${report_excluded_repos[@]}" | jq -R -s 'split("\n")[:-1]'
  fi
}
