dashboard "organization_plan_seats_report" {
  title = "GitHub Organization Plan Seats Report"
  documentation = file("./dashboards/organization/docs/organization_plan_seats_report.md")
  
  tags = merge(local.organization_common_tags, {
    type = "Report"
  })

  container {
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

query "organization_paid_plan_seats_unused_count" {
  sql = <<-EOQ
    select
      'Umused Plan Seats' as label,
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
      plan_filled_seats || ' / ' ||
      case
        when plan_name = 'free' then 'n/a'
        else plan_seats::text
      end as "Used Seats",
      url
    from
      github_my_organization;
  EOQ
}