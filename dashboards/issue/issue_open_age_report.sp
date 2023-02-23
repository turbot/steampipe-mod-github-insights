dashboard "issue_open_report" {

  title         = "GitHub Open Issue Age Report"
  documentation = file("./dashboards/issue/docs/issue_open_age_report.md")

  tags = merge(local.issue_common_tags, {
    type = "Report"
  })

  input "repository_full_name" {
    // title = "Select a repository:"
    placeholder = "Select a repository"
    query       = query.repository_input
    width       = 4
  }

  container {

    card {
      width = 2
      query = query.open_issues_count
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }

    card {
      type  = "info"
      width = 2
      query = query.open_issues_30_days_count
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }

    card {
      type  = "info"
      width = 2
      query = query.open_issues_30_90_days_count
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }

    card {
      width = 2
      type  = "info"
      query = query.open_issues_90_365_days_count
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }

    card {
      width = 2
      type  = "info"
      query = query.open_issues_1_year_count
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }

  }

  container {
    table {
      title = "Open Issues"
      query = query.open_issues
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
      column "html_url" {
        display = "none"
      }
      column "Number" {
        href = "{{.'html_url'}}"
      }
    }
  }
}

// TODO: Format and uncomment commented columns
query "open_issues" {
  sql = <<-EOQ
    with issue_tags as (
      select
        issue_number,
        string_agg(t, ', ') as tags
      from
        github_issue,
        jsonb_object_keys(tags) as t
      where
        repository_full_name = $1
        and state = 'open'
      group by
        issue_number
    )
    select
      i.issue_number as "Number",
      substring(title for 100) as "Title",
      author_login as "Author",
      author_association as "Author Association",
      assignee_logins as "Assignees",
      now()::date - created_at::date as "Age in Days",
      now()::date - updated_at::date as "Days since last update",
      html_url,
      t.tags as "Tags"
    from
      github_issue i
      left join issue_tags as t 
        on i.issue_number = t.issue_number
    where
      repository_full_name = $1
      and state = 'open'
    order by 
      "Age in Days" desc
  EOQ

  param "repository_full_name" {}
}


query "open_issues_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Open Issues' as label
    from
      github_issue
    where
      repository_full_name = $1
      and state = 'open';
  EOQ

  param "repository_full_name" {}
}

query "open_issues_30_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '1-30 Days' as label
    from
      github_issue
    where
      repository_full_name = $1
      and state = 'open'
      and (now()::date - created_at::date) <= 30
      and created_at between symmetric now() - '0 days' :: interval and now() - '30 days' :: interval;
  EOQ

  param "repository_full_name" {}
}

query "open_issues_30_90_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '30-90 Days' as label
    from
      github_issue
    where
      repository_full_name = $1
      and state = 'open'
      and created_at between symmetric now() - '30 days' :: interval and now() - '90 days' :: interval;
  EOQ

  param "repository_full_name" {}
}

query "open_issues_90_365_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '90-365 Days' as label
    from
      github_issue
    where
      repository_full_name = $1
      and state = 'open'
      and created_at between symmetric now() - '90 days' :: interval and now() - '365 days' :: interval;
  EOQ

  param "repository_full_name" {}
}

query "open_issues_1_year_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '> 1 Year' as label
    from
      github_issue
    where
      repository_full_name = $1
      and state = 'open'
      and created_at <= now() - '1 year' :: interval;
  EOQ

  param "repository_full_name" {}
}