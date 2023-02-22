locals {
  branch_common_tags = {
    service = "GitHub/Branch"
  }
}

category "branch" {
  title = "Branch"
  color = local.developer_tools_color
  href  = "/github_insights.dashboard.branch_detail?input.repository_full_name={{.properties.'Repository Full Name' | @uri}}&input.branch_name={{.title | @uri}}"
  icon  = "integration_instructions"
}
