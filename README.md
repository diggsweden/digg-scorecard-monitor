# digg-scorecard-monitor

A monitoring tool that tracks OpenSSF Scorecard security scores for DIGG Sweden's open-source repositories on GitHub.

## Overview

This project automatically monitors and reports on the security posture of DIGG Sweden's repositories using the [OpenSSF Scorecard](https://github.com/ossf/scorecard). It provides insights into best practices and security recommendations for open-source projects.

## Contents

- **`reporting/scope.json`** - Defines which repositories to monitor
  - Lists included repositories for monitoring
  - Specifies excluded repositories
  
- **`reporting/database.json`** - Historical scorecard data
  - Stores current and previous scores
  - Tracks commit information and timestamps
  
- **`reporting/openssf-scorecard-report.md`** - Latest scorecard report
  - Summary table of all monitored repositories
  - Links to detailed scorecard reports

## Monitored Repositories

The monitor tracks repositories from the [diggsweden](https://github.com/diggsweden) organization

## Customizing checks
you can customize the checks for each repo at the .github/action where the scores are generated 

## Resources

- [OpenSSF Scorecard](https://github.com/ossf/scorecard) - Security scoring tool
- [Scorecard Visualizer](https://ossf.github.io/scorecard-visualizer/) - Interactive score viewer

