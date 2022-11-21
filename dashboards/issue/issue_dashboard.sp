dashboard "github_issue_dashboard" {

  title = "GitHub Issue Dashboard"
  documentation = file("./dashboards/issue/docs/issue_dashboard.md")

  tags = merge(local.issue_common_tags, {
    type = "Dashboard"
  })

  input "repository_full_name" {
    title = "Select a repository:"
    query = query.github_repository_input
    width = 4
  }

  # Top cards
  container {

    card {
      query = query.github_issue_count
      width = 2
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }
    card {
      query = query.github_issue_open_count
      width = 2
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }

    # Assessment
    card {
      query = query.github_issue_open_longer_than_30_days_count
      width = 2
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }
    card {
      query = query.github_issue_open_unassigned_count
      width = 2
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }
  }

  container {
    title = "Analysis"

    chart {
      title = "Issues By Author Association To The Repo"
      type  = "column"
      width = 4
      query = query.github_issue_by_author_association
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }

    chart {
      title = "Issues By Age"
      type  = "column"
      width = 4
      query = query.github_issue_by_age
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }
  }
}

# Card Queries

query "github_issue_count" {
  sql = <<-EOQ
    select count(*) as "Issues" from github_issue where repository_full_name = $1;
  EOQ

  param "repository_full_name" {}
}
query "github_issue_open_count" {
  sql = <<-EOQ
    select count(*) as "Open Issues" from github_issue where repository_full_name = $1 and state = 'open';
  EOQ

  param "repository_full_name" {}
}

query "github_issue_open_longer_than_30_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Open > 30 days' as label,
      case
        when count(*) > 0 then 'alert'
        else 'ok'
      end as type
    from
      github_issue
    where
      repository_full_name = $1 and
      state = 'open' and
      created_at <= (current_date - interval '30' day);
  EOQ

  param "repository_full_name" {}
}

query "github_issue_open_unassigned_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Open Unassigned' as label,
      case
        when count(*) > 0 then 'alert'
        else 'ok'
      end as type
    from
      github_issue
    where
      repository_full_name = $1
      and jsonb_array_length(assignee_logins) = 0
      and state = 'open';
  EOQ

  param "repository_full_name" {}
}

# Analysis Queries

query "github_issue_by_author_association" {
  sql = <<-EOQ
    select
      initcap(author_association) as "Association",
      count(*) as "issues"
    from
      github_issue
    where
      repository_full_name = $1
    group by
      author_association;
  EOQ

  param "repository_full_name" {}
}

query "github_issue_by_age" {
  sql = <<-EOQ
    select
      to_char(created_at,
          'YYYY-MM') as creation_month,
      count(*) as "issues"
    from
      github_issue
    where
      repository_full_name = $1
    group by
      creation_month;
  EOQ

  param "repository_full_name" {}
}
