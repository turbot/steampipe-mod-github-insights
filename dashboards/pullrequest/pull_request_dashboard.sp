dashboard "pullrequest_dashboard" {

  title = "GitHub Pull Request Dashboard"
  documentation = file("./dashboards/pullrequest/docs/pull_request_dashboard.md")

  tags = merge(local.pull_request_common_tags, {
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
    #   query = query.github_issue_open_unassigned_count
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

  }

  container {
    title = "Analysis"

    chart {
      title = "Pull Requests By Locked State"
      type  = "column"
      width = 4
      query = query.pull_request_by_locked
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }

    chart {
      title = "Pull Requests By Rebaseable"
      type  = "column"
      width = 4
      query = query.pull_request_by_rebaseable
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }

    chart {
      title = "Pull Requests By Milestone"
      type  = "column"
      width = 4
      query = query.pull_request_by_milestone
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }

    chart {
      title = "Pull Requests By Mergeable"
      type  = "column"
      width = 4
      query = query.pull_request_by_mergeable
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }

    chart {
      title = "Pull Requests By Age"
      type  = "column"
      width = 4
      query = query.pull_request_by_age
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
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


query "pull_request_by_locked" {
  sql = <<-EOQ
    select
      locked,
      count(*) as "pull requests"
    from
      github_pull_request
    where
      repository_full_name = $1
    group by
      locked;
  EOQ

  param "repository_full_name" {}
}

query "pull_request_by_rebaseable" {
  sql = <<-EOQ
    select
      case when rebaseable then 'true' else 'false' end as status,
      count(*) as "pull requests"
    from
      github_pull_request
    where
      repository_full_name = $1
    group by
      rebaseable;
  EOQ

  param "repository_full_name" {}
}

query "pull_request_by_milestone" {
  sql = <<-EOQ
    select
      milestone_title,
      count(*) as "pull requests"
    from
      github_pull_request
    where
      repository_full_name = $1
      and milestone_title is not null
    group by
      milestone_title;
  EOQ

  param "repository_full_name" {}
}

query "pull_request_by_mergeable" {
  sql = <<-EOQ
    select
      mergeable_state,
      count(*) as "pull requests"
    from
      github_pull_request
    where
      repository_full_name = $1
      and mergeable is not null
    group by
      mergeable_state;
  EOQ

  param "repository_full_name" {}
}

query "pull_request_by_age" {
  sql = <<-EOQ
    select
      to_char(created_at,
          'YYYY-MM') as creation_month,
      count(*) as "pull requests"
    from
      github_pull_request
    where
      repository_full_name = $1
    group by
      created_at;
  EOQ

  param "repository_full_name" {}
}

