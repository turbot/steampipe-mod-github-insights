dashboard "organization_plan_seats_report" {
  title = "GitHub Organization Plan Seats Report"
  documentation = file("./dashboards/organization/docs/organization_plan_seats_report.md")
  
  tags = merge(local.organization_common_tags, {
    type = "Report"
  })

  container {
    card {
      query = query.organization_paid_plan_seats_count
      width = 2
    }

    card {
      query = query.organization_paid_plan_seats_used_count
      width = 2
    }

    card {
      query = query.organization_paid_plan_seats_unused_count
      width = 2
    }
  }

  container {
    table {
      title = "Plan Seating Information"
      query = query.organization_plan_seats_table

      column "url" {
        display = "none"
      }

      column "Organization" {
        href = "{{.'url'}}"
      }
    }
  }
}

query "organization_paid_plan_seats_count" {
  sql = <<-EOQ
    select
      'Paid Plan Seats' as label,
      sum(plan_seats) as value,
      'info' as type
    from
      github_my_organization
    where plan_name <> 'free';
  EOQ
}

query "organization_paid_plan_seats_used_count" {
  sql = <<-EOQ
    select
      'Paid Plan Used Seats' as label,
      sum(plan_filled_seats) as value,
      'info' as type
    from
      github_my_organization
    where plan_name <> 'free';
  EOQ
}

query "organization_paid_plan_seats_unused_count" {
  sql = <<-EOQ
    select
      'Paid Plan Used Seats' as label,
      sum(plan_seats) - sum(plan_filled_seats) as value,
      case
        when (sum(plan_seats) - sum(plan_filled_seats)) > 0 then 'alert'
        else 'ok'
      end as type
    from
      github_my_organization
    where plan_name <> 'free';
  EOQ
}

query "organization_plan_seats_table" {
  sql = <<-EOQ
    select
      login as "Organization",
      plan_name as "Plan Name",
      plan_seats as "Plan Seats",
      plan_filled_seats as "Used Seats",
      case
        when (plan_seats - plan_filled_seats) < 0 then 0
        else (plan_seats - plan_filled_seats)
      end as "Available Seats",
      url
    from
      github_my_organization;
  EOQ
}