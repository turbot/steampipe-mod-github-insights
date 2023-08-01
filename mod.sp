// Benchmarks and controls for specific services should override the "service" tag
locals {
  github_insights_common_tags = {
    plugin  = "github"
    service = "GitHub"
  }
}

mod "github_insights" {
  # hub metadata
  title         = "GitHub Insights"
  description   = "Create dashboards and reports for your GitHub resources using Steampipe."
  color         = "#191717"
  documentation = file("./docs/index.md")
  icon          = "/images/mods/turbot/github-insights.svg"
  categories    = ["github", "dashboard"]

  opengraph {
    title       = "Steampipe Mod for GitHub Insights"
    description = "Create dashboards and reports for your GitHub resources using Steampipe."
    image       = "/images/mods/turbot/github-insights-social-graphic.png"
  }

  require {
    steampipe = "0.18.0"
    plugin "github" {
      version = "0.29.0"
    }
  }
}
