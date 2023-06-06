mod "github_insights" {
  # hub metadata
  title         = "GitHub Insights"
  description   = "Create dashboards and reports for your GitHub resources using Steampipe."
  color         = "#0089D6"
  documentation = file("./docs/index.md")
  icon          = "/images/mods/turbot/github-insights.svg"
  categories    = ["github", "dashboard", "public cloud"]

  opengraph {
    title       = "Steampipe Mod for GitHub Insights"
    description = "Create dashboards and reports for your GitHub resources using Steampipe."
    image       = "/images/mods/turbot/github-insights-social-graphic.png"
  }

  # TODO: Include require block for min version of Steampipe / GitHub plugin
}