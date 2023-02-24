edge "team_to_team" {
  title = "team"

  sql = <<-EOQ
    select
      parent ->> 'slug' as from_id,
      slug as to_id
    from
      github_team
    where
      organization_login = any($1)
      and parent is not null;
  EOQ

  param "organization_logins" {}
}

edge "team_to_user" {
  title = "member"

  sql = <<-EOQ
    with non_team_members as (
      select
        login
      from 
        github_organization_member 
      where 
        organization = $1
      except
      select
        distinct login
      from
        github_team_member
      where
        organization = $1
        and slug = any($2)
    )select
      slug as from_id,
      login as to_id
    from
      github_team_member
    where
      organization = $1
      and slug = any($2)
  EOQ

  param "organization_logins" {}
  param "team_slugs" {}
}

edge "team_to_repository" {
  title = "repository"

  sql = <<-EOQ
    with non_team_repos as (
      select
        full_name
      from 
        github_my_repository 
      where 
        owner_login = $1
      except
      select
        distinct full_name
      from
        github_team_repository
      where
        organization = $1
        and slug = any($2)
    )select
      slug as from_id,
      full_name as to_id
    from
      github_team_repository
    where
      organization = $1
      and slug = any($2)
  EOQ

  param "organization_logins" {}
  param "team_slugs" {}
}