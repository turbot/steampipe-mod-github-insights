edge "team_to_team" {
  title = "team"

  sql = <<-EOQ
    with recursive subordinates as (
      select
        slug as to_id,
        parent ->> 'slug' as from_id
      from
        github_team
      where
        organization_login = any($1)
        and slug = any($2)
      union
        select
          t.slug as to_id,
          t.parent ->> 'slug' as from_id
        from
          github_team t
        inner join subordinates s on s.to_id = t.parent ->> 'slug'
    )select
      *
    from
      subordinates;
  EOQ

  param "organization_logins" {}
  param "team_slugs" {}
}

edge "team_to_user" {
  title = "member"

  sql = <<-EOQ
    select
      t.slug as from_id,
      tm.login as to_id
    from
      github_my_team as t,
      github_team_member as tm
    where
      t.organization = $1
      and tm.organization = $1
      and t.slug = tm.slug;
  EOQ

  param "organization_logins" {}
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