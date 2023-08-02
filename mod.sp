// Benchmarks and controls for specific services should override the "service" tag
locals {
  github_insights_common_tags = {
    plugin  = "github"
    service = "GitHub"
  }
}

variable "common_dimensions" {
  type        = list(string)
  description = "A list of common dimensions to add to each control."
  # Define which common dimensions should be added to each control.
  # - connection_name (_ctx ->> 'connection_name')
  default = []
}

locals {

  # Local internal variable to build the SQL select clause for common
  # dimensions using a table name qualifier if required. Do not edit directly.
  common_dimensions_qualifier_sql = <<-EOQ
  %{~if contains(var.common_dimensions, "connection_name")}, __QUALIFIER___ctx ->> 'connection_name' as connection_name%{endif~}

  EOQ
}

locals {

  # Local internal variable with the full SQL select clause for common
  # dimensions. Do not edit directly.
  common_dimensions_sql = replace(local.common_dimensions_qualifier_sql, "__QUALIFIER__", "")

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
