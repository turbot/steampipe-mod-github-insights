dashboard "branch_activity_report" {
  title = "GitHub Branch Activity Report"
  documentation = file("./dashboards/branch/docs/branch_activity_report.md")

  tags = merge(local.branch_common_tags, {
    type = "Report"
  })

  container {
    card {
      query = query.branches_count
      width = 2
    }

    card {
      query = query.branch_activity_24_hours_count
      width = 2
    }

    card {
      query = query.branch_activity_30_days_count
      width = 2
    }

    card {
      query = query.branch_activity_30_90_day_count
      width = 2
    }

    card {
      query = query.branch_activity_90_365_day_count
      width = 2
    }

    card {
      query = query.branch_activity_1_year_count
      width = 2
    }
  }

  container {
    table {
      title = "Branch Activity"
      query = query.branch_activity_table

      column "url" {
        display = "none"
      }

      column "commit_url" {
        display = "none"
      }

      column "author_url" {
        display = "none"
      }

      column "Repository" {
        href = "{{.'url'}}"
      }

      column "Commit Sha" {
        href = "{{.'commit_url'}}"
      }

      column "Commit Author" {
        href = "{{.'author_url'}}"
      }
    }
  }
}

query "branches_count" {
  sql = <<-EOQ
    select
      'Branches' as label,
      count(*) as value
    from
      github_my_repository r
    join
      github_branch b
    on b.repository_full_name = r.name_with_owner
  EOQ
}

query "branch_activity_24_hours_count" {
  sql = <<-EOQ
    select
      '< 24 Hours' as label,
      count(*) as value
    from
      github_my_repository r
    join
      github_branch b
    on b.repository_full_name = r.name_with_owner
    where
      (b.commit ->> 'authored_date')::date > now() - '1 days'::interval;
  EOQ
}

query "branch_activity_30_days_count" {
  sql = <<-EOQ
    select
      '1-30 Days' as label,
      count(*) as value
    from
      github_my_repository r
    join
      github_branch b
    on b.repository_full_name = r.name_with_owner
    where
      (b.commit ->> 'authored_date')::date between symmetric now() - '1 days' :: interval and now() - '30 days' :: interval;
  EOQ
}

query "branch_activity_30_90_day_count" {
  sql = <<-EOQ
    select
      '30-90 Days' as label,
      count(*) as value
    from
      github_my_repository r
    join
      github_branch b
    on b.repository_full_name = r.name_with_owner
    where
      (b.commit ->> 'authored_date')::date between symmetric now() - '30 days' :: interval and now() - '90 days' :: interval;
  EOQ
}

query "branch_activity_90_365_day_count" {
  sql = <<-EOQ
    select
      '90-365 Days' as label,
      count(*) as value,
      case
        when count(*) > 0 then 'alert'
        else 'ok'
      end as type
    from
      github_my_repository r
    join
      github_branch b
    on b.repository_full_name = r.name_with_owner
    where
      (b.commit ->> 'authored_date')::date between symmetric now() - '90 days' :: interval and now() - '365 days' :: interval;
  EOQ
}

query "branch_activity_1_year_count" {
  sql = <<-EOQ
    select
      '> 1 Year' as label,
      count(*) as value,
      case
        when count(*) > 0 then 'alert'
        else 'ok'
      end as type
    from
      github_my_repository r
    join
      github_branch b
    on b.repository_full_name = r.name_with_owner
    where
      (b.commit ->> 'authored_date')::date <= now() - '1 year' :: interval;
  EOQ
}

query "branch_activity_table" {
  sql = <<-EOQ
    select
      r.name_with_owner as "Repository",
      b.name as "Branch",
      now()::date - (b.commit ->> 'authored_date')::date as "Last Commit in Days",
      b.commit -> 'author' -> 'user' ->> 'login' as "Commit Author",
      b.commit ->> 'sha' as "Commit Sha",
      r.url as "url",
      b.commit ->> 'url' as "commit_url",
      b.commit -> 'author' -> 'user' ->> 'url' as "author_url"
    from
      github_my_repository r
    join
      github_branch b
    on b.repository_full_name = r.name_with_owner
    order by
      "Last Commit in Days" desc;
  EOQ
}