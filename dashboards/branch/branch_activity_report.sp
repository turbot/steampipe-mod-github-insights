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
      query = query.branch_activity_last_week_count
      width = 2
    }

    card {
      query = query.branch_activity_8_to_30_day_count
      width = 2
    }

    card {
      query = query.branch_activity_31_to_90_day_count
      width = 2
    }

    card {
      query = query.branch_activity_91_to_180_day_count
      width = 2
    }

    card {
      query = query.branch_activity_over_180_day_count
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

query "branch_activity_last_week_count" {
  sql = <<-EOQ
    select
      'Last week' as label,
      count(*) as value
    from
      github_my_repository r
    join
      github_branch b
    on b.repository_full_name = r.name_with_owner
    where
      (now()::date - (b.commit ->> 'authored_date')::date) <= 7;
  EOQ
}

query "branch_activity_8_to_30_day_count" {
  sql = <<-EOQ
    select
      '8-30 Days' as label,
      count(*) as value
    from
      github_my_repository r
    join
      github_branch b
    on b.repository_full_name = r.name_with_owner
    where
      (now()::date - (b.commit ->> 'authored_date')::date) BETWEEN 8 AND 30;
  EOQ
}

query "branch_activity_31_to_90_day_count" {
  sql = <<-EOQ
    select
      '31-90 Days' as label,
      count(*) as value
    from
      github_my_repository r
    join
      github_branch b
    on b.repository_full_name = r.name_with_owner
    where
      (now()::date - (b.commit ->> 'authored_date')::date) BETWEEN 31 AND 90;
  EOQ
}

query "branch_activity_91_to_180_day_count" {
  sql = <<-EOQ
    select
      '91-180 Days' as label,
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
      (now()::date - (b.commit ->> 'authored_date')::date) BETWEEN 91 AND 180;
  EOQ
}

query "branch_activity_over_180_day_count" {
  sql = <<-EOQ
    select
      '> 180 Days' as label,
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
      (now()::date - (b.commit ->> 'authored_date')::date) > 180;
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