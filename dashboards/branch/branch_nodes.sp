node "branch" {
  category = category.branch

  sql = <<-EOQ
    select
      name as id,
      name as title,
      jsonb_build_object(
        'Repository Full Name', repository_full_name,
        'Protected', protected,
        'Commit URL', commit_url,
        'Commit Sha', commit_sha
      ) as properties
    from
      github_branch
    where
      name = any($1)
      and repository_full_name = any($2)
  EOQ

  param "branch_names" {}
  param "repository_full_names" {}
}
