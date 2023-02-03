locals {
  branch_common_tags = {
    service = "GitHub/Branch"
  }
}

category "branch" {
  title = "Branch"
  color = local.developer_tools_color
  icon  = "integration_instructions"
}
