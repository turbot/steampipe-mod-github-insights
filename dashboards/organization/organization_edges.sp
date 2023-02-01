edge "organization_to_repository" {
  title = "repository"

  sql = <<-EOQ
    select
      o.id as from_id,
      r.id as to_id
    from
      github_my_organization o,
      github_my_repository r
    where
      o.login = r.owner_login
      and o.login = any($1);
  EOQ

  param "organization_logins" {}
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
      organization_id as from_id,
      id as to_id
    from
      github_team
    where
      organization_login = any($1);
  EOQ

  param "organization_logins" {}
}

edge "organization_to_user" {
  title = "member"

  sql = <<-EOQ
    with member_details as (
      select
        om.login as member_login,
        o.login as org_login,
        o.id as org_id
      from
        github_my_organization as o
      join github_organization_member om
        on om.organization = o.login
      join jsonb_array_elements(o.members) as m
        on om.login = m.value ->> 'login'
      where
        o.login = any($1)
      order by
        om.role, upper(om.login)
    )select
      m.org_id as from_id,
      u.id as to_id
    from
      member_details m,
      github_user u
    where
      u.login = m.member_login;
  EOQ

  param "organization_logins" {}
}