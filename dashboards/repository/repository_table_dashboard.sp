dashboard "github_repository_dashboard" {

  title         = "GitHub Repository Dashboard"
  // documentation = file("./dashboards/repository/docs/repository_dashboard.md")

  tags = merge(local.repository_common_tags, {
    type = "Dashboard"
  })

  # Top cards
  container {

    # Analysis
    card {
      sql   = query.github_repository_count.sql
      width = 2
    }
    card {
      sql   = query.github_repository_public_count.sql
      width = 2
    }
    card {
      sql   = query.github_repository_private_count.sql
      width = 2
    }

    # Assessments
    card {
      sql = query.github_repository_public_pr_disabled_count.sql
      width = 2
    }
    card {
      sql = query.github_repository_private_pr_disabled_count.sql
      width = 2
    }
    card {
      sql = query.github_repository_less_than_two_admins_count.sql
      width = 2
    }

  }

}

# Card Queries

query "github_repository_count" {
  sql = <<-EOQ
    select count(*) as "Repositories" from github_my_repository;
  EOQ
}

query "github_repository_public_count" {
  sql = <<-EOQ
    select count(*) as "Public" from github_my_repository where visibility = 'public';
  EOQ
}

query "github_repository_private_count" {
  sql = <<-EOQ
    select count(*) as "Private" from github_my_repository where visibility = 'private';
  EOQ
}

query "github_repository_public_pr_disabled_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Public: PR Review Disabled' as label,
      case
        when b.required_pull_request_reviews is not null then 'ok'
        else 'alert'
      end as type
    from
      github_my_repository as r
      left join github_branch_protection as b
    on
      r.full_name = b.repository_full_name and
      r.default_branch = b.name
    where
      visibility = 'public' and
      r.fork = false
    group by
      b.required_pull_request_reviews;
  EOQ
}

query "github_repository_private_pr_disabled_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Private: PR Review Disabled' as label,
      case
        when b.required_pull_request_reviews is not null then 'ok'
        else 'alert'
      end as type
    from
      github_my_repository as r
      left join github_branch_protection as b
    on
      r.full_name = b.repository_full_name and
      r.default_branch = b.name
    where
      visibility = 'private' and
      r.fork = false
    group by
      b.required_pull_request_reviews;
  EOQ
}

query "github_repository_less_than_two_admins_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Less Than Tow Admins' as label,
      case
        when count(c -> 'permissions' ->> 'admin') >= 2 then 'ok'
        else 'alert'
      end as type
    from
      github_my_repository,
      jsonb_array_elements(collaborators) as c
    where
      (c -> 'permissions' ->> 'admin')::bool
    group by
      html_url,
      full_name;
  EOQ
}
