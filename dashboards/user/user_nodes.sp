node "user" {
  category = category.user

  sql = <<-EOQ
    select
      login as id,
      login as title,
      jsonb_build_object(
        'ID', id,
        'Creation Date', created_at,
        'Site Admin', site_admin,
        'Creation Date', created_at,
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
