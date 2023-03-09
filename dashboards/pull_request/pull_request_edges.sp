edge "pull_request_to_reviewer" {
  title = "reviewer"
  sql   = <<-EOQ
   select
      r.issue_number as from_id,
      u.login as to_id
    from
      github_pull_request as r,
      jsonb_array_elements_text(requested_reviewer_logins) as l
      left join github_user as u on u.login = l
    where
      issue_number = any($1)
      and repository_full_name = $2
  EOQ

  param "pull_request_ids" {}
  param "repository_full_names" {}
}

edge "pull_request_to_assignee" {
  title = "assignee"
  sql   = <<-EOQ
   select
      r.issue_number as from_id,
      u.login as to_id
    from
      github_pull_request as r,
      jsonb_array_elements_text(assignee_logins) as l
      left join github_user as u on u.login = l
    where
      issue_number = any($1)
      and repository_full_name = $2
  EOQ

  param "pull_request_ids" {}
  param "repository_full_names" {}
}

edge "pull_request_to_commit" {
  title = "commit"

  sql = <<-EOQ
   select
      issue_number as from_id,
      merge_commit_sha as to_id
    from
      github_pull_request
    where
      issue_number  = $1
      and repository_full_name = $2
  EOQ

  param "pull_request_ids" {}
  param "repository_full_names" {}
}

edge "pull_request_to_branch" {
  title = "base ref"

  sql = <<-EOQ
   select
      issue_number as from_id,
      base_ref as to_id
    from
      github_pull_request
    where
      repository_full_name = any($1)
      and base_ref = any($2)
      and state = 'open'
  EOQ

  param "repository_full_names" {}
  param "branch_names" {}
}

edge "branch_to_pull_request" {
  title = "pr"

  sql = <<-EOQ
   select
      head_ref as from_id,
      issue_number as to_id
    from
      github_pull_request
    where
      repository_full_name = any($1)
      and head_ref = any($2)
      and state = 'open'
  EOQ

  param "repository_full_names" {}
  param "branch_names" {}
}