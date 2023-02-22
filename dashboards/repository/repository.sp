locals {
  repository_common_tags = {
    service = "GitHub/Repository"
  }
}

category "repository" {
  title = "Repository"
  color = local.developer_tools_color
  href  = "/github_insights.dashboard.repository_detail?input.repository_full_name={{.id | @uri}}"
  // icon  = "flowsheet"
  icon = "rebase_edit"
}
