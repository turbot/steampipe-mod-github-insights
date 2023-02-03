locals {
  issue_common_tags = {
    service = "GitHub/Issue"
  }
}

category "issue" {
  title = "Issue"
  color = local.developer_tools_color
  # href  = "/aws_insights.dashboard.dax_cluster_detail?input.dax_cluster_arn={{.properties.'ARN' | @uri}}"
  icon = "description"
}