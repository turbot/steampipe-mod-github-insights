dashboard "pull_request_open_report" {

  title         = "GitHub Open Pull Request Age Report"
  documentation = file("./dashboards/pull_request/docs/pull_request_open_age_report.md")

  tags = merge(local.pull_request_common_tags, {
    type = "Report"
  })

  input "repository_full_names" {
    placeholder = "Select a repository"
    type        = "multicombo"
    query       = query.repository_input
    width       = 4
  }

  container {

    card {
      width = 2
      query = query.open_pull_requests_count
      args = {
        repository_full_names = self.input.repository_full_names.value
      }
    }

    card {
      type  = "info"
      width = 2
      query = query.open_pull_requests_30_days_count
      args = {
        repository_full_names = self.input.repository_full_names.value
      }
    }

    card {
      type  = "info"
      width = 2
      query = query.open_pull_requests_30_90_days_count
      args = {
        repository_full_names = self.input.repository_full_names.value
      }
    }

    card {
      width = 2
      type  = "info"
      query = query.open_pull_requests_90_365_days_count
      args = {
        repository_full_names = self.input.repository_full_names.value
      }
    }

    card {
      width = 2
      type  = "info"
      query = query.open_pull_requests_1_year_count
      args = {
        repository_full_names = self.input.repository_full_names.value
      }
    }

  }

  container {
    table {
      title = "Open Pull Requests"
      query = query.open_pull_requests
      args = {
        repository_full_names = self.input.repository_full_names.value
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
query "open_pull_requests" {
  sql = <<-EOQ
    with pull_request_tags as (
      select
        issue_number,
        string_agg(t, ', ') as tags
      from
        github_pull_request,
        jsonb_object_keys(tags) as t
      where
        repository_full_name = any(string_to_array($1, ','))
        and state = 'open'
      group by
        issue_number
    )
    select
      i.issue_number as "Number",
      substring(title for 100) as "Title",
      now()::date - created_at::date as "Age in Days",
      now()::date - updated_at::date as "Days Since Last Update",
      author_login as "Author",
      repository_full_name as "Repository",
      case 
        when author_association = 'NONE' then 'External' 
        else initcap(author_association) 
      end as "Author Association",
      --array_to_string(assignee_logins, ',') as "Assignees",
      assignee_logins as "Assignees",
      html_url,
      t.tags as "Tags"
    from
      github_pull_request i
      left join pull_request_tags as t 
        on i.issue_number = t.issue_number
    where
      repository_full_name = any(string_to_array($1, ','))
      and state = 'open'
    order by 
      "Age in Days" desc
  EOQ

  param "repository_full_names" {}
}


query "open_pull_requests_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Open Pull Requests' as label
    from
      github_pull_request
    where
      repository_full_name = any(string_to_array($1, ','))
      and state = 'open';
  EOQ

  param "repository_full_names" {}
}

query "open_pull_requests_30_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '1-30 Days' as label
    from
      github_pull_request
    where
      repository_full_name = any(string_to_array($1, ','))
      and state = 'open'
      and (now()::date - created_at::date) <= 30
      and created_at between symmetric now() - '0 days' :: interval and now() - '30 days' :: interval;
  EOQ

  param "repository_full_names" {}
}

query "open_pull_requests_30_90_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '30-90 Days' as label
    from
      github_pull_request
    where
      repository_full_name = any(string_to_array($1, ','))
      and state = 'open'
      and created_at between symmetric now() - '30 days' :: interval and now() - '90 days' :: interval;
  EOQ

  param "repository_full_names" {}
}

query "open_pull_requests_90_365_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '90-365 Days' as label
    from
      github_pull_request
    where
      repository_full_name = any(string_to_array($1, ','))
      and state = 'open'
      and created_at between symmetric now() - '90 days' :: interval and now() - '365 days' :: interval;
  EOQ

  param "repository_full_names" {}
}

query "open_pull_requests_1_year_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '> 1 Year' as label
    from
      github_pull_request
    where
      repository_full_name = any(string_to_array($1, ','))
      and state = 'open'
      and created_at <= now() - '1 year' :: interval;
  EOQ

  param "repository_full_names" {}
}