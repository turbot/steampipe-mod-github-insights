dashboard "github_organization_dashboard" {

  title = "GitHub Organization Dashboard"
  // documentation = file("./dashboards/organization/docs/organization_dashboard.md")

  tags = merge(local.organization_common_tags, {
    type = "Dashboard"
  })

  # Top cards
  container {

    # Analysis
    card {
      query = query.github_organization_count
      width = 2
    }

  }

}

# Card Queries

query "github_organization_count" {
  sql = <<-EOQ
    select count(*) as "Organizations" from github_my_organization;
  EOQ
}
