locals {
  organization_common_tags = {
    service = "GitHub/Organization"
  }
}

category "organization" {
  title = "Organization"
  color = local.developer_tools_color
  href  = "/github_insights.dashboard.organization_detail?input.organization_login={{.title | @uri}}"
  icon = "diversity_2"
}