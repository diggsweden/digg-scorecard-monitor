#!/usr/bin/env bash

scorecard_workflow_urls() {
  local org="$1"
  local repo="$2"

  gh api "repos/$org/$repo/contents/.github/workflows" \
    --jq '.[] | select(.type == "file") | .download_url' 2>/dev/null || true
}

scorecard_workflow_uses_approved_ref() {
  local url="$1"
  local approved_prefix="$2"
  local content
  local line
  local key
  local value
  local ref

  content="$(curl -fsSL "$url")" || return 1

  while IFS= read -r line; do
    line="${line#"${line%%[![:space:]]*}"}"
    read -r key value _ <<< "$line"

    if [ "$key" = "uses:" ] && [[ "$value" == "$approved_prefix"* ]]; then
      ref="${value#"$approved_prefix"}"
      [[ "$ref" =~ ^[0-9a-f]{40}$ ]] && return 0
    fi
  done <<< "$content"

  return 1
}

scorecard_repo_uses_approved_workflow() {
  local org="$1"
  local repo="$2"
  local approved_prefix="$3"
  local url
  local urls

  urls="$(scorecard_workflow_urls "$org" "$repo")"
  [ -n "$urls" ] || return 1

  while IFS= read -r url; do
    [ -n "$url" ] || continue
    scorecard_workflow_uses_approved_ref "$url" "$approved_prefix" && return 0
  done <<< "$urls"

  return 1
}
