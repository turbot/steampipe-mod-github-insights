edge "repository_to_branch" {
  title = "branch"

  sql = <<-EOQ
    select
      r.full_name as from_id,
      b.name as to_id
    from
      github_branch as b
      left join github_my_repository as r on r.full_name = b.repository_full_name
    where
      b.name = any($1)
      and b.repository_full_name = any($2)
  EOQ

  param "branch_names" {}
  param "repository_full_names" {}
}

edge "repository_to_pull_request" {
  title = "pull request"

  sql = <<-EOQ
    select
      r.full_name as from_id,
      b.issue_number as to_id
    from
      github_pull_request as b
      left join github_my_repository as r on r.full_name = b.repository_full_name
    where
      b.issue_number = any($1)
      and b.repository_full_name = $2
  EOQ

  param "pull_request_ids" {}
  param "repository_full_names" {}
}

edge "repository_to_tag" {
  title = "tag"

  sql = <<-EOQ
    select
      repository_full_name as from_id,
      name as to_id
    from
      github_tag
    where
      repository_full_name = any($1);
  EOQ

  param "repository_full_names" {}
}

edge "repository_to_external_collaborators" {
  title = "external collaborator"

  sql = <<-EOQ
    select
      r.full_name as from_id,
      u.login as to_id
    from
      github_my_repository as r,
      jsonb_array_elements_text(outside_collaborator_logins) as l
      left join github_user as u on u.login = l
    where
      r.full_name = any($1)
  EOQ

  param "repository_full_names" {}
}

edge "repository_to_internal_collaborators" {
  title = "internal collaborator"

  sql = <<-EOQ
    with internal_collaborators as (
      select
        collaborator.value ->> 0 as collaborator,
        r.full_name as repository_id
      from
        github_my_repository as r,
        jsonb_array_elements(collaborator_logins) as collaborator
      where
        r.full_name = any($1)
      except
      select
        collaborator.value ->> 0 as collaborator,
         r.full_name as repository_id
      from
        github_my_repository as r,
        jsonb_array_elements(outside_collaborator_logins) as collaborator
      where
        r.full_name = any($1)
    )
    select
      repository_id as from_id,
      u.login as to_id
    from
      internal_collaborators as c
      left join github_user as u on u.login = c.collaborator
  EOQ

  param "repository_full_names" {}
}

