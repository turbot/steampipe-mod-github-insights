query "organization_count" {
  sql = <<-EOQ
    select
      count(*) as "Organizations"
    from
      github_my_organization;
  EOQ
}