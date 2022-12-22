locals {
  pull_request_common_tags = {
    service = "GitHub/PullRequest"
  }
}

category "pull_request" {
  title = "Pull Request"
  color = local.developer_tools_color
  # href  = "/github_insights.dashboard.pull_request_detail?input.repository_full_name={{.properties.'ARN' | @uri}}"
  icon  = "text:PR"
}
