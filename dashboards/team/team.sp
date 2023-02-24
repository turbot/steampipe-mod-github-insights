locals {
  team_common_tags = {
    service = "GitHub/Team"
  }
}

category "team" {
  title = "Team"
  color = local.iam_color
  href  = "/github_insights.dashboard.team_detail?input.organization_team_slug_input={{.properties.'Full Name' | @uri}}"
  icon  = "groups"
}
