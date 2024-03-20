## v0.5 [2024-03-20]

_Bug fixes_

- Fixed the `repository_weak_copyleft_license_count`, `repository_other_license_count` and `repository_license_table `queries to use the latest version of EUP (European Union Public License). ([#25](https://github.com/turbot/steampipe-mod-github-insights/pull/25))

## v0.4 [2024-03-06]

_Powerpipe_

[Powerpipe](https://powerpipe.io) is now the preferred way to run this mod! [Migrating from Steampipe →](https://powerpipe.io/blog/migrating-from-steampipe)

All v0.x versions of this mod will work in both Steampipe and Powerpipe, but v1.0.0 onwards will be in Powerpipe format only.

_Enhancements_

- Focus documentation on Powerpipe commands.
- Show how to combine Powerpipe mods with Steampipe plugins.

## v0.3 [2023-11-03]

_Breaking changes_

- Updated the plugin dependency section of the mod to use `min_version` instead of `version`. ([#18](https://github.com/turbot/steampipe-mod-github-insights/pull/18))

## v0.2 [2023-07-26]

_Bug fixes_

- Fixed the brand color of the mod icon.

## v0.1 [2023-07-26]

_What's new?_

- New dashboards added:
  - [Default Branch Protection Report](https://hub.steampipe.io/mods/turbot/github_insights/dashboards/dashboard.default_branch_protection_report)
  - [Open Issue Age Report](https://hub.steampipe.io/mods/turbot/github_insights/dashboards/dashboard.issue_open_age_report)
  - [Organization Member Privileges Report](https://hub.steampipe.io/mods/turbot/github_insights/dashboards/dashboard.organization_member_privileges_report)
  - [Organization 2FA Report](https://hub.steampipe.io/mods/turbot/github_insights/dashboards/dashboard.organization_2fa_report)
  - [Organization Plan Seat Report](https://hub.steampipe.io/mods/turbot/github_insights/dashboards/dashboard.organization_plan_seat_report)
  - [Organization Security Advisory Report](https://hub.steampipe.io/mods/turbot/github_insights/dashboards/dashboard.organization_security_advisory_report)
  - [Open Pull Request Age Report](https://hub.steampipe.io/mods/turbot/github_insights/dashboards/dashboard.pull_request_open_age_report)
  - [Repository License Report](https://hub.steampipe.io/mods/turbot/github_insights/dashboards/dashboard.repository_license_report)
  - [Repository Security Advisory Report](https://hub.steampipe.io/mods/turbot/github_insights/dashboards/dashboard.repository_security_advisory_report)
  - [Repository Stargazers Report](https://hub.steampipe.io/mods/turbot/github_insights/dashboards/dashboard.repository_stargazer_report)
  - [Repository Visibility Report](https://hub.steampipe.io/mods/turbot/github_insights/dashboards/dashboard.repository_visibility_report)
