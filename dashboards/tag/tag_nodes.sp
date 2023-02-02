node "tag" {
  category = category.tag

  sql = <<-EOQ
    select
      name as id,
      name as title,
      jsonb_build_object(
        'Commit SHA', commit_sha
      ) as properties
    from
      github_tag
    where
      repository_full_name = any($1)
  EOQ

  param "repository_full_names" {}
}
