dashboard "issue_open_report" {

  title         = "GitHub Open Issue Report"
  documentation = file("./dashboards/issue/docs/issue_open_report.md")

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
      query = query.open_issues_label_stale
      width = 2
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }

    card {
      width = 2
      query = query.open_issues_label_bug
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }

    card {
      width = 2
      query = query.open_issues_label_help_wanted
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
      width = 2
      type  = "info"
      query = query.open_issues_30_90_days_count
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }

    card {
      width = 2
      type  = "info"
      query = query.open_issues_90_days_count
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
    select
      issue_number as "Number",
      substring(title for 100) as "Title",
      author_login as "Author",
      assignee_logins as "Assignees",
      created_at as "Created At",
      html_url,
      locked as "Locked",
      milestone_title as "Milestone"
    from
      github_issue, jsonb_array_elements(assignee_logins) as assignees
    where
      repository_full_name = $1 and
      state = 'open'
    order by issue_number desc;
  EOQ

  param "repository_full_name" {}
}

query "open_issues_label_stale" {
  sql = <<-EOQ
    select 
      count(*) as value,
      'Stale Issues' as label
    from 
      github_issue,
      jsonb_object_keys(tags) tag
    where 
      repository_full_name = $1
      and tag = 'stale'
      and state = 'open'
    group by tag
  EOQ

  param "repository_full_name" {}
}

query "open_issues_label_bug" {
  sql = <<-EOQ
    select 
      count(*) as value,
      'Open Bugs' as label
    from 
      github_issue,
      jsonb_object_keys(tags) tag
    where 
      repository_full_name = $1
      and tag = 'bug'
      and state = 'open'
    group by tag
  EOQ

  param "repository_full_name" {}
}

query "open_issues_label_help_wanted" {
  sql = <<-EOQ
    select 
      count(*) as value,
      'Help Wanted' as label
    from 
      github_issue,
      jsonb_object_keys(tags) tag
    where 
      repository_full_name = $1
      and tag = 'help wanted'
      and state = 'open'
    group by tag
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
      and created_at between symmetric now() - '1 days' :: interval and now() - '30 days' :: interval;
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

query "open_issues_90_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      '> 90 Days' as label
    from
      github_issue
    where
      repository_full_name = $1
      and state = 'open'
      and created_at <= now() - '90 days' :: interval;
  EOQ

  param "repository_full_name" {}
}