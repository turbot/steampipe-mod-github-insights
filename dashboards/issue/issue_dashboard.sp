dashboard "issue_dashboard" {

  title         = "GitHub Issue Dashboard"
  documentation = file("./dashboards/issue/docs/issue_dashboard.md")

  tags = merge(local.issue_common_tags, {
    type = "Dashboard"
  })

  input "repository_full_name" {
    // title = "Select a repository:"
    placeholder = "Select a repository"
    query       = query.repository_input
    width       = 4
  }

  # Top cards
  container {

    card {
      query = query.issue_count
      width = 3
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }
    card {
      query = query.issue_open_count
      width = 3
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }

    # Assessment
    card {
      query = query.issue_open_longer_than_30_days_count
      width = 3
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }
    card {
      query = query.issue_open_unassigned_count
      width = 3
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }
  }

  container {
    title = "Analysis"

    chart {
      title = "Issues by State"
      type  = "column"
      width = 4
      query = query.issues_by_state
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }

    chart {
      title = "Issues by Tag"
      type  = "column"
      width = 4
      query = query.issues_by_tag
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }

    chart {
      title = "Issues By Age"
      type  = "column"
      width = 4
      query = query.issue_by_age
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }
  }
}

# Card Queries

query "issue_count" {
  sql = <<-EOQ
    select count(*) as "Issues" from github_issue where repository_full_name = $1;
  EOQ

  param "repository_full_name" {}
}
query "issue_open_count" {
  sql = <<-EOQ
    select count(*) as "Open Issues" from github_issue where repository_full_name = $1 and state = 'open';
  EOQ

  param "repository_full_name" {}
}

query "issue_open_longer_than_30_days_count" {
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

query "issue_open_unassigned_count" {
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

query "issues_by_state" {
  sql = <<-EOQ
    select
      state as "State",
      count(i.*) as total
    from
      github_issue i
    where
      repository_full_name = $1
    group by 
      state
    order by 
      total;
  EOQ

  param "repository_full_name" {}
}

query "issues_by_tag" {
  sql = <<-EOQ
    select
      t as "Tag",
      count(i.*) as total
    from
      github_issue i,
      jsonb_object_keys(tags) t
    where
      repository_full_name = $1
    group by 
      t
    order by 
      total;
  EOQ

  param "repository_full_name" {}
}

query "issue_by_age" {
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
