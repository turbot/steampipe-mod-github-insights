dashboard "github_pull_request_dashboard" {

  title = "GitHub Pull Request Dashboard"
  # documentation = file("./dashboards/pull_request/docs/pull_request_dashboard.md")

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
      query = query.github_pull_request_count
      width = 2
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }

    card {
      query = query.github_pull_request_draft_count
      width = 2
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }

    # Assessment
    card {
      query = query.github_pull_request_no_reviewers_count
      width = 2
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }

    card {
      query = query.github_pull_request_open_longer_than_30_days_count
      width = 2
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }
  }

  container {
    title = "Assessments"
    chart {
      title = "Pull Requests with no reviewers"
      query = query.github_pull_request_no_reviewers
      type  = "donut"
      width = 3
      args = {
        repository_full_name = self.input.repository_full_name.value
      }

      series "count" {
        point "Assigned" {
          color = "ok"
        }
        point "Unassigned" {
          color = "alert"
        }
      }
    }
  }

  container {
    title = "Analysis"

    chart {
      title = "Pull Requests By Author Association To The Repo"
      type  = "column"
      width = 4
      query = query.github_pull_request_by_author_association
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }

    chart {
      title = "Pull Requests By Age"
      type  = "column"
      width = 4
      query = query.github_pull_request_by_age
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }
  }
}

# Card Queries

query "github_pull_request_count" {
  sql = <<-EOQ
    select 
      'Pull Requests' as label,
      count(*) as value 
      from
        github_pull_request 
      where 
        repository_full_name = $1 and
        state <> 'closed' ;
  EOQ

  param "repository_full_name" {}
}

query "github_pull_request_draft_count" {
  sql = <<-EOQ
    select 
      'Draft Pull Requests' as label,
      count(*) as value
      from
        github_pull_request 
      where 
        repository_full_name = $1 and
        state <> 'closed' and
        draft;
  EOQ

  param "repository_full_name" {}
}

query "github_pull_request_no_reviewers_count" {
  sql = <<-EOQ
    select 
      'No reviewers' as label,
      count(*) as value,
      case
        when count(*) > 0 then 'alert'
        else 'ok'
      end as type
    from
      github_pull_request
    where 
      repository_full_name = $1 and
      state <> 'closed' and
      jsonb_array_length(requested_reviewer_logins) = 0;
  EOQ

  param "repository_full_name" {}
}

query "github_pull_request_open_longer_than_30_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Open > 30 days' as label,
      case
        when count(*) > 0 then 'alert'
        else 'ok'
      end as type
    from
      github_pull_request
    where
      repository_full_name = $1 and
      state <> 'closed' and
      created_at <= (current_date - interval '30' day);
  EOQ

  param "repository_full_name" {}
}

# Assessments
query "github_pull_request_no_reviewers" {
  sql = <<-EOQ
    with prs as (
      select
        case
          when jsonb_array_length(requested_reviewer_logins) > 0 then 'Assigned' 
          else 'Unassigned' 
        end as reviewer_status
      from
        github_pull_request
      where
        repository_full_name = $1 and
        state <> 'closed'
    )
    select
      reviewer_status,
      count(*)
    from
      prs
    group by
      reviewer_status
  EOQ

  param "repository_full_name" {}
}

# Analysis Queries
query "github_pull_request_by_author_association" {
  sql = <<-EOQ
    select
      initcap(author_association) as "Association",
      count(*)
    from
      github_pull_request
    where
      repository_full_name = $1 and
      state <> 'closed'
    group by
      author_association;
  EOQ

  param "repository_full_name" {}
}

query "github_pull_request_by_age" {
  sql = <<-EOQ
    select
      to_char(created_at,'YYYY-MM') as creation_month,
      count(*)
    from
      github_pull_request
    where
      repository_full_name = $1 and
      state <> 'closed'
    group by
      creation_month;
  EOQ

  param "repository_full_name" {}
}
