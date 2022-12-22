node "user" {
  category = category.user

  sql = <<-EOQ
    select
      id as id,
      login as title,
      jsonb_build_object(
        'ID', id,
        'Created At', created_at,
        'Site Admin', site_admin,
        'Created At', created_at,
        'Two Factor Authentication', two_factor_authentication,
        'Type', type
      ) as properties
    from
      github_user
    where
      login = any($1)
  EOQ

  param "logins" {}
}
