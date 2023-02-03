locals {
  commit_common_tags = {
    service = "GitHub/Commit"
  }
}

category "commit" {
  title = "Commit"
  color = local.developer_tools_color
  icon  = "commit"
}
