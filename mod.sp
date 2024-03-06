mod "github_insights" {
  # Hub metadata
  title         = "GitHub Insights"
  description   = "Create dashboards and reports for your GitHub resources using Powerpipe and Steampipe."
  color         = "#191717"
  documentation = file("./docs/index.md")
  icon          = "/images/mods/turbot/github-insights.svg"
  categories    = ["github", "dashboard"]

  opengraph {
    title       = "Powerpipe Mod for GitHub Insights"
    description = "Create dashboards and reports for your GitHub resources using Powerpipe and Steampipe."
    image       = "/images/mods/turbot/github-insights-social-graphic.png"
  }

  require {
    plugin "github" {
      min_version = "0.29.0"
    }
  }
}
