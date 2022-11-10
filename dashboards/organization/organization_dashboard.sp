dashboard "github_organization_dashboard" {

  title = "GitHub Organization Dashboard"
  // documentation = file("./dashboards/organization/docs/organization_dashboard.md")

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
    select count(*) as "Unverified Domains" from github_my_organization where not is_verified;
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
      name,
      followers as "organizations"
    from
      github_my_organization
    order by name;
  EOQ
}

