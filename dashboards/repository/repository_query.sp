query "repository_input" {
  sql = <<-EOQ
    select
      name_with_owner as label,
      name_with_owner as value
    from
      github_my_repository
    order by
      name_with_owner
  EOQ
}

query "repository_count" {
  sql = <<-EOQ
    select
      count(*) as "Repository Count"
    from
      github_my_repository;
  EOQ
}