locals {
  issue_common_tags = {
    service = "GitHub/Issue"
  }
}

category "issue" {
  title = "Issue"
  color = local.developer_tools_color
  icon = "description"
}