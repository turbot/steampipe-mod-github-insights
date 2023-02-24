node "team" {
  category = category.team

  sql = <<-EOQ
    select
      slug as id,
      name as title,
      jsonb_build_object(
        'ID', id,
        'Members Count', members_count,
        'Permission', permission,
        'Privacy', privacy,
        'Repos Count', repos_count,
        'Slug', slug,
        'Full Name', organization_login || '/' || slug
      ) as properties
    from
      github_my_team
    where
      organization_login = any($1)
      and slug = any($2);
  EOQ

  param "organization_logins" {}
  param "team_slugs" {}
}
