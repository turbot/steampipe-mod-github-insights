dashboard "github_repository_dashboard" {

  title = "GitHub Repository Dashboard"
  // documentation = file("./dashboards/repository/docs/repository_dashboard.md")

  tags = merge(local.repository_common_tags, {
    type = "Dashboard"
  })

  # Top cards
  container {

    # Analysis
    card {
      query = query.github_repository_count
      width = 2
    }
    card {
      query = query.github_repository_public_count
      width = 2
    }
    card {
      query = query.github_repository_private_count
      width = 2
    }

    # Assessments
    card {
      query = query.github_repository_public_pr_disabled_count
      width = 2
    }
    card {
      query = query.github_repository_private_pr_disabled_count
      width = 2
    }
    card {
      query = query.github_repository_less_than_two_admins_count
      width = 2
    }

  }

  container {
    title = "Assessments"
    width = 6

    chart {
      title = "PR Review (Public)"
      type  = "donut"
      width = 4
      query = query.github_repository_public_pr_disabled_status

      series "count" {
        point "enabled" {
          color = "ok"
        }
        point "disabled" {
          color = "alert"
        }
      }
    }
    chart {
      title = "PR Review (Private)"
      type  = "donut"
      width = 4
      query = query.github_repository_private_pr_disabled_status

      series "count" {
        point "enabled" {
          color = "ok"
        }
        point "disabled" {
          color = "alert"
        }
      }
    }
    chart {
      title = "Less Than Two Admins"
      type  = "donut"
      width = 4
      query = query.github_repository_less_than_two_admins_status

      series "count" {
        point ">= 2 admins" {
          color = "ok"
        }
        point "< 2 admins" {
          color = "alert"
        }
      }
    }
  }

  container {
    title = "Analysis"

    chart {
      title = "Repositories by Visibility"
      type  = "column"
      width = 4
      query = query.github_repository_by_visibility
    }
    chart {
      title = "Repositories by Licence Key"
      type  = "column"
      width = 4
      query = query.github_repository_by_license_key
    }
    chart {
      title = "Repositories by Age"
      type  = "column"
      width = 4
      query = query.github_repository_by_age
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
      'PR Review Disabled (Public)' as label,
      case
        when count(*) > 0 then 'alert'
        else 'ok'
      end as type
    from
      github_my_repository as r
      left join github_branch_protection as b
    on
      r.full_name = b.repository_full_name and
      r.default_branch = b.name
    where
      visibility = 'public'
      and b.required_pull_request_reviews is null
    group by
      b.required_pull_request_reviews;
  EOQ
}

query "github_repository_private_pr_disabled_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'PR Review Disabled (Private)' as label,
      case
        when count(*) > 0 then 'alert'
        else 'ok'
      end as type
    from
      github_my_repository as r
      left join github_branch_protection as b
    on
      r.full_name = b.repository_full_name and
      r.default_branch = b.name
    where
      visibility = 'private'
      and b.required_pull_request_reviews is null
    group by
      b.required_pull_request_reviews;
  EOQ
}

query "github_repository_less_than_two_admins_count" {
  sql = <<-EOQ
    with admin_repositories as (
      select
        case
          when count(c -> 'permissions' ->> 'admin') >= 2 then true
          else false
        end as has_at_least_two_admins
      from
        github_my_repository,
        jsonb_array_elements(collaborators) as c
      where
        (c -> 'permissions' ->> 'admin')::bool
      group by
        full_name
    )
    select
      count(*) as value,
      'Less Than Two Admins' as label,
      case
        when count(*) > 0 then 'alert'
        else 'ok'
      end as type
    from
      admin_repositories
    where
      not has_at_least_two_admins
    group by has_at_least_two_admins;
  EOQ
}

# Assessments Queries

query "github_repository_public_pr_disabled_status" {
  sql = <<-EOQ
    select
      case
        when b.required_pull_request_reviews is not null then 'enabled'
        else 'disabled'
      end as status,
      count(*)
    from
      github_my_repository as r
      left join github_branch_protection as b
    on
      r.full_name = b.repository_full_name and
      r.default_branch = b.name
    where
      visibility = 'public'
    group by
      status;
  EOQ
}

query "github_repository_private_pr_disabled_status" {
  sql = <<-EOQ
    select
      case
        when b.required_pull_request_reviews is not null then 'enabled'
        else 'disabled'
      end as status,
      count(*)
    from
      github_my_repository as r
      left join github_branch_protection as b
    on
      r.full_name = b.repository_full_name and
      r.default_branch = b.name
    where
      visibility = 'private'
    group by
      status;
  EOQ
}

query "github_repository_less_than_two_admins_status" {
  sql = <<-EOQ
    with admin_repositories as (
      select
        case
          when count(c -> 'permissions' ->> 'admin') >= 2 then true
          else false
        end as has_at_least_two_admins
      from
        github_my_repository,
        jsonb_array_elements(collaborators) as c
      where
        (c -> 'permissions' ->> 'admin')::bool
      group by
        full_name
    )
    select
      case
        when has_at_least_two_admins then '>= 2 admins'
        else '< 2 admins'
      end as status,
      count(*)
    from
      admin_repositories
    group by status;

  EOQ
}

# Analysis Queries

query "github_repository_by_visibility" {
  sql = <<-EOQ
    select
      visibility as "Visibility",
      count(*) as "repositories"
    from
      github_my_repository
    group by visibility
    order by visibility;
  EOQ
}

query "github_repository_by_license_key" {
  sql = <<-EOQ
    select
      case
        when license_key is null then 'none'
        else license_key
      end as "Licence Key",
      count(*) as "repositories"
    from
      github_my_repository
    group by license_key
    order by license_key;
  EOQ
}

query "github_repository_by_age" {
  sql = <<-EOQ
    select
      to_char(created_at,
          'YYYY-MM') as creation_month,
      count(*) as "repositories"
    from
      github_my_repository
    group by creation_month;
  EOQ
}
