dashboard "pullrequest_dashboard" {

  title         = "GitHub Pull Request Dashboard"
  documentation = file("./dashboards/pullrequest/docs/pull_request_dashboard.md")

  tags = merge(local.pull_request_common_tags, {
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
      query = query.pull_request_count
      width = 2
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }
    card {
      query = query.pull_request_open_count
      width = 2
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }

    card {
      query = query.pull_request_closed_count
      width = 2
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }

    card {
      query = query.pull_request_draft_count
      width = 2
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }

    # Assessment
    card {
      query = query.pull_request_without_reviewers
      width = 2
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }
    # card {
    #   query = query.issue_open_unassigned_count
    #   width = 2
    #   args = {
    #     repository_full_name = self.input.repository_full_name.value
    #   }
    # }
  }

  container {

    title = "Assessments"

    chart {
      title = "Without Reviewers"
      query = query.pull_request_by_without_reviewers
      type  = "donut"
      width = 3

      args = {
        repository_full_name = self.input.repository_full_name.value
      }

      series "count" {
        point "with reviewer" {
          color = "ok"
        }
        point "no reviewer" {
          color = "alert"
        }
      }
    }

    chart {
      title = "Open Pull Requests"
      query = query.pull_requests_by_state
      type  = "donut"
      width = 3

      args = {
        repository_full_name = self.input.repository_full_name.value
      }

      series "count" {
        point "closed" {
          color = "ok"
        }
        point "open" {
          color = "alert"
        }
      }
    }

  }

  container {
    title = "Analysis"

    chart {
      title = "Pull Requests by Author"
      type  = "column"
      width = 4
      query = query.pull_requests_by_author_login
      args = {
        repository_full_name = self.input.repository_full_name.value
      }

      series closed {
        title = "Closed PRs"
        color = "#0C457D"
      }
      series open {
        title = "Open PRs"
        color = "#E8702B"
      }
    }

    chart {
      title    = "Pull Requests By Age"
      type     = "area"
      grouping = "stack"
      width    = 4
      query    = query.pull_request_by_age
      args = {
        repository_full_name = self.input.repository_full_name.value
      }

      series closed {
        title = "Closed PRs"
        color = "#0C457D"
      }
      series open {
        title = "Open PRs"
        color = "#E8702B"
      }

    }

  }

  table {
    title = "Pull Requests - Last 7 Days"
    width = 12
    query = query.repository_recent_pull_requests
    args = {
      repository_full_name = self.input.repository_full_name.value
    }
    column "html_url" {
      display = "none"
    }
    column "Issue" {
      href = "{{.'html_url'}}"
    }
  }
}

# Card Queries

query "pull_request_count" {
  sql = <<-EOQ
    select count(*) as "Pull Requests" from github_pull_request where repository_full_name = $1;
  EOQ

  param "repository_full_name" {}
}

query "pull_request_open_count" {
  sql = <<-EOQ
    select
      count(*) as "Open Pull Requests"
    from
      github_pull_request
    where
      repository_full_name = $1
      and state = 'open';
  EOQ

  param "repository_full_name" {}
}

query "pull_request_closed_count" {
  sql = <<-EOQ
    select
      count(*) as "Closed Pull Requests"
    from
      github_pull_request
    where
      repository_full_name = $1
      and state = 'closed';
  EOQ

  param "repository_full_name" {}
}

query "pull_request_draft_count" {
  sql = <<-EOQ
    select
      count(*) as "Draft Pull Requests"
    from
      github_pull_request
    where
      repository_full_name = $1
      and draft;
  EOQ

  param "repository_full_name" {}
}

query "pull_request_without_reviewers" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Without Reviewers' as label,
      case count(*) when 0 then 'ok' else 'alert' end as type
    from
      github_pull_request
    where
      repository_full_name = $1
      and jsonb_array_length(requested_reviewer_logins) = 0;
  EOQ

  param "repository_full_name" {}
}

# Assessment Queries

query "pull_request_by_without_reviewers" {
  sql = <<-EOQ
    select
      reviewers,
      count(*)
    from (
      select
        case when jsonb_array_length(requested_reviewer_logins) = 0 then
          'no reviewer'
        else
          'with reviewer'
        end reviewers
      from
        github_pull_request
      where
        repository_full_name = $1) as t
    group by
      reviewers
    order by
      reviewers;
  EOQ

  param "repository_full_name" {}
}

query "pull_requests_by_state" {
  sql = <<-EOQ
    select
      state as "State",
      count(r.*)
    from
      github_pull_request r
    where
      repository_full_name = $1
    group by 
      state
    order by 
      state;
  EOQ

  param "repository_full_name" {}
}

query "pull_requests_by_author_login" {
  sql = <<-EOQ
    select
      author_login as "author",
      state,
      count(r.*) as total
    from
      github_pull_request r
    where
      repository_full_name = $1
    group by 
      state,
      author_login
    order by 
      total desc;
  EOQ

  param "repository_full_name" {}
}

query "pull_request_by_age" {
  sql = <<-EOQ
    select
      to_char(created_at,
          'YYYY-MM') as creation_month,
      state,
      count(*) as total
    from
      github_pull_request
    where
      repository_full_name = $1
    group by
      created_at,
      state;
  EOQ

  param "repository_full_name" {}
}

