category "organization" {
  title = "Organization"
  icon = "diversity_2"
}

locals {
  organization_common_tags = {
    service = "GitHub/Organization"
  }
}

query "organization_count" {
  sql = <<-EOQ
    select
      count(*) as "Organizations"
    from
      github_my_organization;
  EOQ
}