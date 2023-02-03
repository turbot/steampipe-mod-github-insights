node "commit" {
  category = category.commit

  sql = <<-EOQ
    select
      sha as id,
      sha as title,
      jsonb_build_object(
        'Repository Full Name', repository_full_name,
        'Author', author_login,
        'Author Date', author_date,
        'Verified', verified
      ) as properties
    from
      github_commit
    where
      sha = any($1)
      and repository_full_name = $2;
  EOQ

  param "commit_sha" {}
  param "repository_full_name" {}
}
