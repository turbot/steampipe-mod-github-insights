dashboard "github_organization_dashboard" {

  title = "GitHub Organization Dashboard"
  documentation = file("./dashboards/organization/docs/organization_dashboard.md")

  tags = merge(local.organization_common_tags, {
    type = "Dashboard"
  })

  # Top cards
  container {

    # Analysis
    card {
      query = query.github_organization_count
      width = 2
    }
    card {
      query = query.github_unverified_count
      width = 2
    }

    # Assesment
    card {
      query = query.github_organization_two_factor_requirement_disabled_count
      width = 2
    }
    card {
      query = query.github_organization_less_than_two_admins_count
      width = 2
    }

  }

  container {
    title = "Assessments"
    width = 6

    chart {
      title = "2FA Requirement"
      type  = "donut"
      width = 4
      query = query.github_organization_two_factor_requirement_status

      series "count" {
        point "Enabled" {
          color = "ok"
        }
        point "Disabled" {
          color = "alert"
        }
      }
    }
    chart {
      title = "Less Than Two Admins"
      type  = "donut"
      width = 4
      query = query.github_organization_less_than_two_admins_status

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
      title = "Organizations by Plan Type"
      type  = "column"
      width = 4
      query = query.github_organization_by_plan
    }
    chart {
      title = "Organizations by Number of Followers"
      type  = "column"
      width = 4
      query = query.github_organization_by_number_of_followers
    }
    chart {
      title = "Organizations by Number of Members"
      type  = "column"
      width = 4
      query = query.github_organization_by_number_of_members
    }
  }

}

# Card Queries

query "github_organization_count" {
  sql = <<-EOQ
    select count(*) as "Organizations" from github_my_organization;
  EOQ
}
query "github_unverified_count" {
  sql = <<-EOQ
    select count(*) as "Domain Not Verified" from github_my_organization where not is_verified;
  EOQ
}
query "github_organization_two_factor_requirement_disabled_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '2FA Not Required' as label,
      case
        when count(*) > 0 then 'alert'
        else 'ok'
      end as type
    from
      github_my_organization
    where not two_factor_requirement_enabled;
  EOQ
}
query "github_organization_less_than_two_admins_count" {
  sql = <<-EOQ

    with organizations_admins as (
      select
        o.login as organization,
        count(1) as admins,
        case
          when count(1) >= 2 then true
          else false
        end as at_least_two_admins
      from
        github_my_organization o
      join
        github_organization_member m
      on
        m.organization = o.login and role = 'ADMIN'
      group by
        o.login
    )

    select
      count as value,
      'Less Than Two Admins' as label,
      case
        when count > 0 then 'alert'
        else 'ok'
      end as type
    from (
      select coalesce((
        select count(*)
        from organizations_admins
        where not at_least_two_admins
        group by at_least_two_admins
      ),0) as count
    ) as less_then_two_admins
  EOQ
}

# Assessments Queries

query "github_organization_two_factor_requirement_status" {
  sql = <<-EOQ
    select
      case
        when two_factor_requirement_enabled then 'Enabled'
        else 'Disabled'
      end as status,
      count(*)
    from
      github_my_organization
    group by
      status;
  EOQ
}

query "github_organization_less_than_two_admins_status" {
  sql = <<-EOQ
    with admin_organizartions as (
      select
        case
          when count(m.login) >= 2 then true
          else false
        end as has_at_least_two_admins
      from
        github_organization_member m
        join github_my_organization o on m.organization = o.login
      where
        role = 'ADMIN'
      group by
        m.organization
    )
    select
      case
        when has_at_least_two_admins then '>= 2 admins'
        else '< 2 admins'
      end as status,
      count(*)
    from
      admin_organizartions
    group by status;
  EOQ
}

# Analysis Queries

query "github_organization_by_plan" {
  sql = <<-EOQ
    select
      plan_name as "Plan",
      count(*) as "organizations"
    from
      github_my_organization
    group by plan_name
    order by plan_name;
  EOQ
}
query "github_organization_by_number_of_followers" {
  sql = <<-EOQ
    select
      login,
      followers as "organizations"
    from
      github_my_organization
    order by login;
  EOQ
}
query "github_organization_by_number_of_members" {
  sql = <<-EOQ
    select
      login,
      jsonb_array_length(members) as "organizations"
    from
      github_my_organization
    order by login;
  EOQ
}
