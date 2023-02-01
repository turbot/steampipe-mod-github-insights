node "team" {
  category = category.team

  sql = <<-EOQ
    select
      id as id,
      name as title,
      jsonb_build_object(
        'ID', id,
        'Members Count', members_count,
        'Permission', permission,
        'Privacy', privacy,
        'Repos Count', repos_count,
        'Slug', slug
      ) as properties
    from
      github_my_team
    where
      organization_login = any($1)
  EOQ

  param "organization_logins" {}
}
