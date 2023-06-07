dashboard "issue_open_age_report" {
  title = "GitHub Open Issues Age Report"
  documentation = file("./dashboards/issue/docs/issue_open_age_report.md")

  tags = merge(local.issue_common_tags, {
    type = "Report"
  })

  input "repositories" {
    placeholder = "Select repositories"
    type        = "multicombo"
    query       = query.repository_input
    width       = 4
  }

  container {
    card {
      query = query.open_issues_count
      width = 2
      args  = {
        repositories = self.input.repositories
      }
    }

    card {
      query = query.open_issues_last_30_days_count
      width = 2
      args  = {
        repositories = self.input.repositories
      }
    }

    card {
      query = query.open_issues_30_90_days_count
      width = 2
      args  = {
        repositories = self.input.repositories
      }
    }

    card {
      query = query.open_issues_90_365_days_count
      width = 2
      args  = {
        repositories = self.input.repositories
      }
    }

    card {
      query = query.open_issues_1_year_count
      width = 2
      args  = {
        repositories = self.input.repositories
      }
    }
  }

  container {
    table {
      title = "Open Issues"
      query = query.open_issues_table
      args  = {
        repositories = self.input.repositories
      }

      column "url" {
        display = "none"
      }

      column "Number" {
        href = "{{.'url'}}"
      }
    }
  }
}

query "open_issues_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Open Issues' as label
    from
      github_issue
    where
      repository_full_name = any(string_to_array($1, ','))
      and state = 'OPEN';
  EOQ

  param "repositories" {}
}

query "open_issues_last_30_days_count" {
  sql = <<-EOQ
    select
      'Last 30 Days' as label,
      count(*) as value
    from
      github_issue
    where
      repository_full_name = any(string_to_array($1, ','))
      and state = 'OPEN'
      and (now()::date - created_at::date) <= 30
      and created_at between symmetric now() - '0 days' :: interval and now() - '30 days' :: interval;
  EOQ

  param "repositories" {}
}

query "open_issues_30_90_days_count" {
  sql = <<-EOQ
    select
      '30-90 Days' as label,
      count(*) as value
    from
      github_issue
    where
      repository_full_name = any(string_to_array($1, ','))
      and state = 'OPEN'
      and created_at between symmetric now() - '30 days' :: interval and now() - '90 days' :: interval;
  EOQ

  param "repositories" {}
}

query "open_issues_90_365_days_count" {
  sql = <<-EOQ
    select
      '90-365 Days' as label,
      count(*) as value,
      case
        when count(*) >= 1 then 'alert'
        else 'info'
      end as type
    from
      github_issue
    where
      repository_full_name = any(string_to_array($1, ','))
      and state = 'OPEN'
      and created_at between symmetric now() - '90 days' :: interval and now() - '365 days' :: interval;
  EOQ

  param "repositories" {}
}

query "open_issues_1_year_count" {
  sql = <<-EOQ
    select
      '> 1 Year' as label,
      count(*) as value,
      case
        when count(*) >= 1 then 'alert'
        else 'info'
      end as type
    from
      github_issue
    where
      repository_full_name = any(string_to_array($1, ','))
      and state = 'OPEN'
      and created_at <= now() - '1 year' :: interval;
  EOQ

  param "repositories" {}
}

query "open_issues_table" {
  sql = <<-EOQ
    select
      number as "Number",
      substring(title for 100) as "Title",
      repository_full_name as "Repository",
      now()::date - created_at::date as "Age in Days",
      now()::date - updated_at::date as "Days Since Last Update",
      case 
        when author_association = 'NONE' then 'External' 
        else initcap(author_association) 
      end as "Author Association",
      case
        when assignees_total_count = 0 then false
        else true
      end as "Is Assigned",
      assignees_total_count as "Assignees",
      url
    from
      github_issue
    where
      repository_full_name = any(string_to_array($1, ','))
      and state = 'OPEN'
    order by
      "Age in Days" desc
  EOQ

  param "repositories" {}
}