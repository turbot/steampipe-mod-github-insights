dashboard "stale_branch_report" {
  title = "GitHub Stale Branch Report"
  documentation = file("./dashboards/branch/docs/stale_branch_report.md")

  tags = merge(local.branch_common_tags, {
    type = "Report"
  })

  container {
    card {
      query = query.branches_total_count
      width = 2
    }

    card {
      query = query.stale_branches_count
      width = 2
    }
  }

  container {
    table {
      title = "Stale Branches"
      query = query.stale_branches_table

      column "url" {
        display = "none"
      }

      column "commit_url" {
        display = "none"
      }

      column "Repository" {
        href = "{{.'url'}}"
      }

      column "Commit Sha" {
        href = "{{.'commit_url'}}"
      }
    }
  }
}

query "branches_total_count" {
  sql = <<-EOQ
    select
      'Total Branches' as label,
      count(*) as value
    from
      github_my_repository r
    join
      github_branch b
    on b.repository_full_name = r.name_with_owner
  EOQ
}

query "stale_branches_count" {
  sql = <<-EOQ
    select
      'Stale Branches' as label,
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
      (now()::date - (b.commit ->> 'authored_date')::date) >= 120
  EOQ
}

query "stale_branches_table" {
  sql = <<-EOQ
    select
      r.name_with_owner as "Repository",
      b.name as "Branch",
      age(now()::date, (b.commit ->> 'authored_date')::date) as "Last Commit",
      b.commit ->> 'sha' as "Commit Sha",
      r.url as "url",
      b.commit ->> 'url' as "commit_url"
    from
      github_my_repository r
    join
      github_branch b
    on b.repository_full_name = r.name_with_owner
    and b.name != (r.default_branch_ref ->> 'name')
    where
      (now()::date - (b.commit ->> 'authored_date')::date) >= 120
    order by
      "Last Commit" desc
  EOQ
}