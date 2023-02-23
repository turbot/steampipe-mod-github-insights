node "organization" {
  category = category.organization

  sql = <<-EOQ
    select
      login as id,
      login as title,
      jsonb_build_object(
        'Name', name,
        'Creation Date', created_at,
        'Description', description,
        'Email', email,
        'Is Verified', is_verified,
        'Type', type
      ) as properties
    from
      github_my_organization
    where
      login = any($1);
  EOQ

  param "organization_logins" {}
}
