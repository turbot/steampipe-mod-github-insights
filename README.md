# GitHub Insights Mod for Steampipe

A GitHub dashboarding tool that can be used to view dashboards and reports across all of your GitHub repositories.

<!-- ![image](https://raw.githubusercontent.com/turbot/steampipe-mod-github-insights/main/docs/images/github_dashboard.png) -->

## Overview

Dashboards can help answer questions like:

- How many repositories do I have?
- How many branches do I have?
- What are the PRs in a repository?
- What are the branch protections rules in a repository?

<!-- Dashboards are available for Compute, Key Vault, SQL, and Storage services. -->

## Getting started

### Installation

Download and install Steampipe (https://steampipe.io/downloads). Or use Brew:

```sh
brew tap turbot/tap
brew install steampipe
```

Install the GitHub plugin with [Steampipe](https://steampipe.io):

```sh
steampipe plugin install github
```

Clone:

```sh
git clone https://github.com/turbot/steampipe-mod-github-insights.git
cd steampipe-mod-github-insights
```

### Usage

Start your dashboard server to get started:

```sh
steampipe dashboard
```

By default, the dashboard interface will then be launched in a new browser window at https://localhost:9194. From here, you can view dashboards and reports.

### Credentials

This mod uses the credentials configured in the [Steampipe GitHub plugin](https://hub.steampipe.io/plugins/turbot/github).

### Configuration

No extra configuration is required.

## Contributing

If you have an idea for additional dashboards or just want to help maintain and extend this mod ([or others](https://github.com/topics/steampipe-mod)) we would love you to join the community and start contributing.

- **[Join our Slack community →](https://steampipe.io/community/join)** and hang out with other Mod developers.

Please see the [contribution guidelines](https://github.com/turbot/steampipe/blob/main/CONTRIBUTING.md) and our [code of conduct](https://github.com/turbot/steampipe/blob/main/CODE_OF_CONDUCT.md). All contributions are subject to the [Apache 2.0 open source license](https://github.com/turbot/steampipe-mod-github-insights/blob/main/LICENSE).

Want to help but not sure where to start? Pick up one of the `help wanted` issues:

- [Steampipe](https://github.com/turbot/steampipe/labels/help%20wanted)
- [GitHub Insights Mod](https://github.com/turbot/steampipe-mod-github-insights/labels/help%20wanted)
