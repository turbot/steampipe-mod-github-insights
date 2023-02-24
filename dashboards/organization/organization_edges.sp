edge "organization_to_repository" {
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
      owner_login as from_id,
      om.full_name as to_id
    from 
      github_my_repository om,
      non_team_repos nm
    where
      owner_login = $1
      and nm.full_name = om.full_name
  EOQ

  param "organization_logins" {}
  param "team_slugs" {}
}

// select
//       coalesce(t.id, t.organization_id) as from_id,
//       r.id as to_id
//     from
//       github_my_team t,
//       github_team_repository r
//     where
//       r.organization = t.organization
//       and r.slug = t.slug
//       and t.organization = any($1);

edge "organization_to_team" {
  title = "team"

  sql = <<-EOQ
    select
      organization_login as from_id,
      slug as to_id
    from
      github_team
    where
      organization_login = any($1)
      and parent is null;
  EOQ

  param "organization_logins" {}
}

edge "organization_to_user" {
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
      organization as from_id,
      om.login as to_id
    from 
      github_organization_member om,
      non_team_members nm
    where
      organization = $1
      and nm.login = om.login
  EOQ

  param "organization_logins" {}
  param "team_slugs" {}
}