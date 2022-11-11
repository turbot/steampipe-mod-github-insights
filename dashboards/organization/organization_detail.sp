dashboard "github_organization_detail" {

  title = "GitHub Organization Detail"
  // documentation = file("./details/organization/docs/organization_detail.md")

  tags = merge(local.organization_common_tags, {
    type = "Detail"
  })

  input "organization_login" {
    title = "Select a organization:"
    query = query.github_organization_input
    width = 4
  }
}


query "github_organization_input" {
  sql = <<-EOQ
    select
      login as label,
      login as value
    from
      github_my_organization
    order by
      login;
  EOQ
}
