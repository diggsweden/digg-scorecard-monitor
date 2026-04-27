# digg-scorecard-monitor

Automation for monitoring OpenSSF Scorecard adoption and result data across DIGG Sweden's GitHub repositories.

## Overview

This repository owns generated Scorecard data, scheduled collection and rollout helpers. The handbook/docs repository should own policy text and the human-facing explanation of why Scorecard is mandatory.

If this grows beyond Scorecard into more open-source health reports, keep this as the automation repository and consider renaming the remote repository to a broader name such as `digg-open-source-monitoring` or `digg-open-source-reports`.

## Files

- `reporting/scope.json` is the canonical source for repository scope.
- `reporting/database.json` is generated state with historical Scorecard scores, commits and timestamps.
- `reporting/openssf-scorecard-report.md` is the generated Markdown report for humans.
- `.github/workflows/scorecard-monitor.yml` updates generated report data on a schedule.
- `renovate.json` enables Renovate updates for GitHub Actions dependencies.
- `scripts/append_repos_without_scorecard` adds active, non-excluded repositories without the approved workflow to the report.
- `scripts/generate_scorecard_workflows` generates ready-to-copy per-repository workflow files.
- `scripts/lib/scorecard_workflows.sh` contains shared workflow-inspection helpers.
- `scripts/sort_scorecard_report` sorts the generated Markdown report table.

## Scope

The monitor tracks repositories from the [diggsweden](https://github.com/diggsweden) organization

`reporting/scope.json` is the canonical source for Scorecard scope.

- `included` repositories must run Digg's reusable OpenSSF Scorecard workflow.
- `excluded` repositories are intentionally out of scope.
- Active repositories that are neither included nor excluded should be classified before strict enforcement is enabled.

## CI Support

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
