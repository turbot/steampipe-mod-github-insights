node "repository" {
  category = category.repository

  sql = <<-EOQ
    select
      full_name as id,
      name as title,
      jsonb_build_object(
        'Full Name', full_name,
        'Owner ID', owner_id,
        'Private', private,
        'Git URL', git_url,
        'Size', size,
        'Visibility', visibility
      ) as properties
    from
      github_my_repository
    where
      full_name = any($1);
  EOQ

  param "repository_full_names" {}
}
