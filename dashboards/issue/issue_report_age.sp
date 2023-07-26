dashboard "issue_open_age_report" {
  title = "GitHub Open Issue Age Report"
  documentation = file("./dashboards/issue/docs/issue_report_age.md")

  tags = merge(local.issue_common_tags, {
    type     = "Report"
    category = "Age"
  })

  container {
    card {
      query = query.open_issue_count
      width = 2
    }

    card {
      query = query.open_issue_24_hours_count
      width = 2
      type  = "info"
    }

    card {
      query = query.open_issue_30_days_count
      width = 2
      type  = "info"
    }

    card {
      query = query.open_issue_30_90_days_count
      width = 2
      type  = "info"
    }

    card {
      query = query.open_issue_90_365_days_count
      width = 2
      type  = "info"
    }

    card {
      query = query.open_issue_1_year_count
      width = 2
      type  = "info"
    }
  }

  container {
    table {
      title = "Open Issues"
      query = query.open_issue_table

      column "url" {
        display = "none"
      }

      column "author_url" {
        display = "none"
      }

      column "repo_url" {
        display = "none"
      }

      column "Issue" {
        href = "{{.'url'}}"
        wrap = "all"
      }

      column "Author" {
        href = "{{.'author_url'}}"
      }

      column "Repository" {
        href = "{{.'repo_url'}}"
      }
    }
  }
}

query "open_issue_count" {
  sql = <<-EOQ
    select
      count(i.*) as value,
      'Open Issues' as label
    from
      github_my_repository r
    join
      github_issue i
    on
      i.repository_full_name = r.name_with_owner
    where
      i.state = 'OPEN';
  EOQ
}

query "open_issue_24_hours_count" {
  sql = <<-EOQ
    select
      '< 24 Hours' as label,
      count(i.*) as value
    from
      github_my_repository r
      join github_issue i on i.repository_full_name = r.name_with_owner
    where
      i.state = 'OPEN'
      and i.created_at > now() - '1 days'::interval;
  EOQ
}

query "open_issue_30_days_count" {
  sql = <<-EOQ
    select
      '1-30 Days' as label,
      count(i.*) as value
    from
      github_my_repository r
      join github_issue i on i.repository_full_name = r.name_with_owner
    where
      i.state = 'OPEN'
      and i.created_at between symmetric now() - '1 days' :: interval and now() - '30 days' :: interval;
  EOQ
}

query "open_issue_30_90_days_count" {
  sql = <<-EOQ
    select
      '30-90 Days' as label,
      count(i.*) as value
    from
      github_my_repository r
      join github_issue i on i.repository_full_name = r.name_with_owner
    where
      i.state = 'OPEN'
      and i.created_at between symmetric now() - '30 days' :: interval and now() - '90 days' :: interval;
  EOQ
}

query "open_issue_90_365_days_count" {
  sql = <<-EOQ
    select
      '90-365 Days' as label,
      count(i.*) as value
    from
      github_my_repository r
      join github_issue i on i.repository_full_name = r.name_with_owner
    where
      i.state = 'OPEN'
      and i.created_at  between symmetric now() - '90 days' :: interval and now() - '365 days' :: interval;
  EOQ
}

query "open_issue_1_year_count" {
  sql = <<-EOQ
    select
      '> 1 Year' as label,
      count(i.*) as value
    from
      github_my_repository r
      join github_issue i on i.repository_full_name = r.name_with_owner
    where
      i.state = 'OPEN'
      and i.created_at <= now() - '1 year' :: interval;
  EOQ
}

query "open_issue_table" {
  sql = <<-EOQ
    select
      '#' || number || ' ' || title as "Issue",
      repository_full_name as "Repository",
      now()::date - i.created_at::date as "Age in Days",
      now()::date - i.updated_at::date as "Days Since Last Update",
      author ->> 'login' as "Author",
      author ->> 'url' as "author_url",
      case
        when author_association = 'NONE' then 'External'
        else initcap(author_association)
      end as "Author Association",
      i.url,
      r.url as repo_url
    from
      github_my_repository r
      join github_issue i on i.repository_full_name = r.name_with_owner
    where
      i.state = 'OPEN'
    order by
      "Age in Days" desc;
  EOQ
}