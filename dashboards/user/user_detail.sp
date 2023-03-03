dashboard "user_detail" {

  title         = "GitHub User Detail"
  documentation = file("./dashboards/user/docs/user_detail.md")

  tags = merge(local.user_common_tags, {
    type = "Detail"
  })

  input "user_input" {
    placeholder = "Enter a user name"
    width       = 4
    type        = "text"
  }


  # Top cards
  container {
    card {
      query = query.user_followers_count
      width = 2
      args = {
        user_login = self.input.user_input.value
      }
    }

    card {
      query = query.user_repositories_contributed_to_count
      width = 2
      args = {
        user_login = self.input.user_input.value
      }
    }

    card {
      query = query.user_total_issue_contributions_count
      width = 2
      args = {
        user_login = self.input.user_input.value
      }
    }

    card {
      query = query.user_total_pull_request_contributions_count
      width = 2
      args = {
        user_login = self.input.user_input.value
      }
    }

    card {
      query = query.user_total_pull_request_review_contributions_count
      width = 2
      args = {
        user_login = self.input.user_input.value
      }
    }

    card {
      query = query.user_two_factor_authentication_disabled
      width = 2
      args = {
        user_login = self.input.user_input.value
      }
    }
  }

  container {

    table {
      title = "Overview"
      type  = "line"
      width = 3
      query = query.user_overview
      args = {
        user_login = self.input.user_input.value
      }
    }

    chart {
      title    = "Contribution Trends"
      type     = "area"
      grouping = "stack"
      width    = 9
      query    = query.user_contribution_trends
      args = {
        user_login = self.input.user_input.value
      }

      // series closed {
      //   title = "Closed Issues"
      //   color = "#0C457D"
      // }
      // series open {
      //   title = "Open Issues"
      //   color = "#E8702B"
      // }

    }
  }

  container {
    title = "Analysis"

    chart {
      title = "Created PRs by Repositories - Top 10"
      type  = "column"
      width = 6
      query = query.user_pull_requests_by_repositories
      args = {
        user_login = self.input.user_input.value
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
      title = "Requested Review PRs by Repositories - Top 10"
      type  = "column"
      width = 6
      query = query.user_reviewed_pull_requests_by_repositories
      args = {
        user_login = self.input.user_input.value
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
      title = "Assigned Issues by Repositories - Top 10"
      type  = "column"
      width = 6
      query = query.user_issues_by_repositories
      args = {
        user_login = self.input.user_input.value
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
      title = "Commits by Repositories - Top 10"
      type  = "column"
      width = 6
      query = query.user_commits_by_repositories
      args = {
        user_login = self.input.user_input.value
      }

      series total {
        title = "Commits"
        color = "#0C457D"
      }
    }

  }
}


query "user_followers_count" {
  sql = <<-EOQ
    select
      followers as "Total Followers" 
    from 
      github_user 
    where 
      login = $1;
  EOQ

  param "user_login" {}
}

query "user_repositories_contributed_to_count" {
  sql = <<-EOQ
    select
      repositories_contributed_to_count as "Repositories Contributed To" 
    from 
      github_user 
    where 
      login = $1;
  EOQ

  param "user_login" {}
}

query "user_total_issue_contributions_count" {
  sql = <<-EOQ
    select
      contributions_collection ->> 'TotalIssueContributions' as "Issues Contributed" 
    from 
      github_user 
    where 
      login = $1;
  EOQ

  param "user_login" {}
}

query "user_total_pull_request_contributions_count" {
  sql = <<-EOQ
    select
      contributions_collection ->> 'TotalPullRequestContributions' as "Pull Requests Contributed" 
    from 
      github_user 
    where 
      login = $1;
  EOQ

  param "user_login" {}
}

query "user_total_pull_request_review_contributions_count" {
  sql = <<-EOQ
    select
      contributions_collection ->> 'TotalPullRequestReviewContributions' as "Pull Requests Reviewed" 
    from 
      github_user 
    where 
      login = $1;
  EOQ

  param "user_login" {}
}

query "user_two_factor_authentication_disabled" {
  sql = <<-EOQ
    select
      'Two Factor Authentication' as label,
      case 
        when two_factor_authentication then 'Enabled' 
        else 'Disabled' 
      end as value,
      case 
        when two_factor_authentication then 'ok' 
        else 'alert' 
      end as type
    from 
      github_user 
    where 
      login = $1;
  EOQ

  param "user_login" {}
}

query "user_overview" {
  sql = <<-EOQ
    select
      id as "ID",
      name as "Name",
      type as "Type",
      email as "Email",
      company as "Company",
      created_at as "Creation Date",
      location as "Location",
      public_repos as "Total Public Repos",
      starred_repositories_count as "Starred Repositories",
      sponsoring as "Sponsoring",
      sponsors as "Sponsors"
    from
      github_user
    where
      login = $1;
  EOQ

  param "user_login" {}
}

query "user_pull_requests_by_repositories" {
  sql = <<-EOQ
    select
      repository_full_name as "Repo",
      state,
      count(*) as total
    from
      github_search_pull_request
    where
      query = 'author:' || $1
    group by 
      repository_full_name,
      state
    order by 
      total desc
    limit 10;
  EOQ

  param "user_login" {}
}

query "user_reviewed_pull_requests_by_repositories" {
  sql = <<-EOQ
    select
      repository_full_name as "Repo",
      state,
      count(*) as total
    from
      github_search_pull_request
    where
      query = 'review-requested:' || $1
    group by 
      repository_full_name,
      state
    order by 
      total desc
    limit 10;
  EOQ

  param "user_login" {}
}

query "user_issues_by_repositories" {
  sql = <<-EOQ
    select
      repository_full_name as "Repo",
      state,
      count(*) as total
    from
      github_search_issue
    where
      query = 'assignee:' || $1
    group by 
      repository_full_name,
      state
    order by 
      total desc
    limit 10;
  EOQ

  param "user_login" {}
}

query "user_commits_by_repositories" {
  sql = <<-EOQ
    select
      repository_full_name as "Repo",
      count(*) as total
    from
      github_search_commit
    where
      query = 'author:' || $1
    group by 
      repository_full_name
    order by 
      total desc
    limit 10;
  EOQ

  param "user_login" {}
}

query "user_contribution_trends" {
  sql = <<-EOQ
    with commit_trend as (
      select
        to_char((commit -> 'author' ->> 'date')::date, 'YYYY-MM') as created_month,
        count(*) as commit_total
      from
        github_search_commit
      where
        query = 'author:' || $1
      group by 
        created_month
    ), pr_author_trend as (
      select
        to_char(created_at, 'YYYY-MM') as created_month,
        count(*) as pr_author_total
      from
        github_search_pull_request
      where
        query = 'author:' || $1
      group by 
        created_month
    ), pr_review_trend as (
      select
        to_char(created_at, 'YYYY-MM') as created_month,
        count(*) as pr_review_total
      from
        github_search_pull_request
      where
        query = 'review-requested:' || $1
      group by 
        created_month
    ), issue_trend as (
      select
        to_char(created_at, 'YYYY-MM') as created_month,
        count(*) as issue_total
      from
        github_search_issue
      where
        query = 'assignee:' || $1
      group by 
        created_month
    ) select
      COALESCE(ct.created_month, pat.created_month, prt.created_month, it.created_month) as create_time,
      COALESCE(commit_total, 0) as "Commits",
      COALESCE(pr_author_total, 0) as "Pull Requests",
      COALESCE(pr_review_total, 0) as "Pull Requests Reviews",
      COALESCE(issue_total, 0) as "Issues"
    from
      commit_trend ct
      full join pr_author_trend pat on ct.created_month = pat.created_month
      full join pr_review_trend prt on ct.created_month = prt.created_month
      full join issue_trend it on ct.created_month = it.created_month
    order by
      create_time
  EOQ

  param "user_login" {}
}