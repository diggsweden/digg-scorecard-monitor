# digg-scorecard-monitor

Automation for monitoring OpenSSF Scorecard adoption, REUSE API registration, SCA/Renovate setup, CODEOWNERS coverage and related report data across DIGG Sweden's GitHub repositories.

## Overview

This repository owns manual collection and generated report data for Digg's public GitHub repositories.
The handbook/docs repository owns policy text and renders the public report pages from the structured JSON files generated here.

If this grows beyond Scorecard into more open-source health reports, keep this as the automation repository and consider renaming the remote repository to a broader name such as `digg-open-source-monitoring` or `digg-open-source-reports`.

## Workflow

Run the GitHub Actions workflow `Generate repository reports` (`.github/workflows/scorecard-monitor.yml`) manually when report data should be refreshed.
The workflow:

1. Generates `reporting/repositories.json`, the shared list of public repositories.
2. Runs `ossf/scorecard-monitor` to update Scorecard Markdown and historical state.
3. Checks active repositories in OpenSSF Scorecard scope for Digg's approved reusable Scorecard workflow.
4. Generates structured JSON reports for OpenSSF Scorecard, REUSE API registration, SCA/Renovate setup and CODEOWNERS coverage.
5. Commits generated files under `reporting/` when data changed.

Only `scripts/list_public_repositories` lists repositories from the GitHub organization API. Other report scripts consume `reporting/repositories.json` so every report uses the same repository universe.

## Files

- `reporting/scope.json` is the canonical source for OpenSSF Scorecard included and excluded repositories.
- `reporting/repositories.json` is generated repository metadata shared by all report generators.
- `reporting/report-exclusions.json` contains manually maintained per-report exclusions.
- `reporting/database.json` is generated state with historical OpenSSF Scorecard scores, commits and timestamps.
- `reporting/openssf-scorecard-report.md` is the generated OpenSSF Scorecard Markdown report for humans.
- `reporting/openssf-scorecard-report.json` is the structured OpenSSF Scorecard report consumed by `opensource-docs`.
- `reporting/reuse-report.json` is the structured REUSE API registration report consumed by `opensource-docs`.
- `reporting/sca-renovate-report.json` is the structured SCA/Renovate report consumed by `opensource-docs`.
- `reporting/codeowners-report.json` is the structured CODEOWNERS report consumed by `opensource-docs`.
- `.github/workflows/scorecard-monitor.yml` updates generated report data when run manually.
- `renovate.json` enables Renovate updates for GitHub Actions dependencies.
- `scripts/list_public_repositories` generates the shared public repository list once per workflow run.
- `scripts/append_repos_without_scorecard` adds active, non-excluded repositories from the shared repository list without the approved workflow to the Markdown report and can emit workflow-status JSON.
- `scripts/generate_scorecard_report_json` generates the structured JSON report from Scorecard data and workflow-status data.
- `scripts/generate_reuse_report_json` generates the structured JSON report from the shared repository list and the REUSE API.
- `scripts/generate_sca_renovate_report_json` generates the structured JSON report from the shared repository list and Renovate config.
- `scripts/generate_codeowners_report_json` generates the structured JSON report from the shared repository list and CODEOWNERS files.
- `scripts/generate_scorecard_workflows` generates ready-to-copy per-repository workflow files.
- `scripts/lib/scorecard_workflows.sh` contains shared workflow-inspection helpers.
- `scripts/sort_scorecard_report` sorts the generated Markdown report table.

## Scope

The monitor tracks public repositories from the [diggsweden](https://github.com/diggsweden) organization.

`reporting/scope.json` is the canonical source for OpenSSF Scorecard scope only.
REUSE, SCA/Renovate and CODEOWNERS use the generated public repository list plus their own keys in `reporting/report-exclusions.json`.

- `included` repositories must run Digg's reusable OpenSSF Scorecard workflow.
- `excluded` repositories are intentionally out of OpenSSF Scorecard scope.
- Active public repositories that are neither included nor excluded are still visible in the OpenSSF Scorecard report unless explicitly filtered out by that report.

## Report Contracts

The structured JSON reports are the data contract for `opensource-docs`.
Do not parse `reporting/openssf-scorecard-report.md` in downstream consumers; it is human-facing only.

`reporting/repositories.json` includes public repositories, including archived repositories. Report generators filter to active, non-private repositories when applying checks.

`reporting/report-exclusions.json` has one top-level list per report: `openssf_scorecard`, `reuse`, `sca_renovate` and `codeowners`.
Each item must contain `repo` and may contain `reason`.
Report generators validate the file and fail if an excluded repository is not present in `reporting/repositories.json`.
Use report-specific exclusions when a repository should stay visible in other reports but not be checked by one specific report.

Example:

```json
{
  "openssf_scorecard": [],
  "reuse": [
    { "repo": "example-docs", "reason": "Documentation-only repository." }
  ],
  "sca_renovate": [],
  "codeowners": []
}
```

REUSE registration means the repository has status data in the REUSE API used by the REUSE badge.

SCA/Renovate base preset detection accepts Digg's shared Renovate base configuration in local preset form and GitHub preset form.

CODEOWNERS coverage means a repository has a `CODEOWNERS` file in one of GitHub's supported locations and at least one non-comment owner rule. The report also lists the owners parsed from those rules.

## Local Use

Generate the shared repository list:

```sh
GITHUB_TOKEN=... bash scripts/list_public_repositories
```

Generate the REUSE report from the shared list:

```sh
bash scripts/generate_reuse_report_json
```

Generate the SCA/Renovate report from the shared list:

```sh
bash scripts/generate_sca_renovate_report_json
```

Generate the CODEOWNERS report from the shared list:

```sh
bash scripts/generate_codeowners_report_json
```

The OpenSSF Scorecard JSON report normally needs the `ossf/scorecard-monitor` workflow output plus workflow-status JSON, so it is generated by the manual workflow.

## Scorecard Workflow Rollout

No score thresholds are enforced by this repository. Score thresholds should be introduced separately if the organisation later wants class-based gates.

Generate workflows for all included repositories:

```sh
bash scripts/generate_scorecard_workflows
```

Generate a workflow for one included repository:

```sh
bash scripts/generate_scorecard_workflows --repo wallet-provider
```

The generated workflow files are written under `generated/openssf-scorecard-workflows/`, which is git-ignored. They can be copied manually or used by automation that opens repository pull requests.

## Customising Checks

Project-specific Scorecard behaviour should be handled through the reusable workflow in `diggsweden/reusable-ci`. Keep repository-local workflows thin so organisation-wide changes can be rolled out centrally.

## Resources

- [OpenSSF Scorecard](https://github.com/ossf/scorecard) - Security scoring tool
- [Scorecard Visualizer](https://ossf.github.io/scorecard-visualizer/) - Interactive score viewer
