locals {
  release_common_tags = {
    service = "GitHub/Release"
  }
}

category "release" {
  title = "Release"
  color = local.developer_tools_color
  icon = "description"
}