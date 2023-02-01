locals {
  organization_common_tags = {
    service = "GitHub/Organization"
  }
}

category "organization" {
  title = "Organization"
  color = local.developer_tools_color
  # href  = "/aws_insights.dashboard.dax_cluster_detail?input.dax_cluster_arn={{.properties.'ARN' | @uri}}"
  icon = "flowsheet"
}