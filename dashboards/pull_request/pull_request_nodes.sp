node "pull_request" {
  category = category.pull_request

  sql = <<-EOQ
    select
      issue_number as id,
      title as title,
      jsonb_build_object(
        'ID', id,
        'Repository Full Name', repository_full_name,
        'Issue Number', issue_number,
        'Author Login', author_login,
        'Creation Date', created_at,
        'Locked', locked,
        'Merged', merged,
        'State', state
      ) as properties
    from
      github_pull_request
    where
      issue_number = any($2)
      and repository_full_name = $1
  EOQ

  param "repository_full_name" {}
  param "pull_request_ids" {}
}


