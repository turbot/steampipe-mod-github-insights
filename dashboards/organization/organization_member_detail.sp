dashboard "organization_member_detail" {

  title         = "GitHub Organization Member Detail"
  documentation = file("./dashboards/organization/docs/organization_member_detail.md")

  tags = merge(local.organization_common_tags, {
    type = "Detail"
  })

  input "organization_login" {
    placeholder = "Select an organization"
    query       = query.organization_input
    width       = 4
  }

  input "organization_member_login" {
    placeholder = "Select a member"
    query       = query.organization_member_input
    width       = 4
    args = {
      organization_login = self.input.organization_login.value
    }
  }

  # Top cards
  container {
    card {
      query = query.organization_member_followers_count
      width = 2
      args = {
        organization_member_login = self.input.organization_member_login.value
      }
    }

    // card {
    //   query = query.organization_member_repositories_contributed_to_count
    //   width = 2
    //   args = {
    //     organization_member_login = self.input.organization_member_login.value
    //   }
    // }

    // card {
    //   query = query.organization_member_total_issue_contributions_count
    //   width = 2
    //   args = {
    //     organization_member_login = self.input.organization_member_login.value
    //   }
    // }

    // card {
    //   query = query.organization_member_total_pull_request_contributions_count
    //   width = 2
    //   args = {
    //     organization_member_login = self.input.organization_member_login.value
    //   }
    // }

    // card {
    //   query = query.organization_member_total_pull_request_review_contributions_count
    //   width = 2
    //   args = {
    //     organization_member_login = self.input.organization_member_login.value
    //   }
    // }

    card {
      query = query.organization_member_two_factor_authentication_disabled
      width = 2
      args = {
        organization_member_login = self.input.organization_member_login.value
      }
    }
  }

  container {

    table {
      title = "Overview"
      type  = "line"
      width = 3
      query = query.organization_member_overview
      args = {
        organization_member_login = self.input.organization_member_login.value
        organization_login        = self.input.organization_login.value
      }
    }

    chart {
      title    = "Contribution Trends"
      type     = "area"
      grouping = "stack"
      width    = 9
      query    = query.organization_member_contribution_trends
      args = {
        organization_member_login = self.input.organization_member_login.value
        organization_login        = self.input.organization_login.value
      }

    }
  }

  container {
    title = "Analysis"

    chart {
      title = "Created PRs by Repositories - Top 10"
      type  = "column"
      width = 6
      query = query.organization_member_pull_requests_by_repositories
      args = {
        organization_member_login = self.input.organization_member_login.value
        organization_login        = self.input.organization_login.value
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
      query = query.organization_member_reviewed_pull_requests_by_repositories
      args = {
        organization_member_login = self.input.organization_member_login.value
        organization_login        = self.input.organization_login.value
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
      query = query.organization_member_issues_by_repositories
      args = {
        organization_member_login = self.input.organization_member_login.value
        organization_login        = self.input.organization_login.value
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
      query = query.organization_member_commits_by_repositories
      args = {
        organization_member_login = self.input.organization_member_login.value
        organization_login        = self.input.organization_login.value
      }

      series total {
        title = "Commits"
        color = "#0C457D"
      }
    }

  }
}

query "organization_member_input" {
  sql = <<-EOQ
    select
      login as label,
      login as value
    from
      github_organization_member
    where
      organization = $1
    order by
      login;
  EOQ

  param "organization_login" {}
}

query "organization_member_followers_count" {
  sql = <<-EOQ
    select
      followers as "Total Followers" 
    from 
      github_user 
    where 
      login = $1;
  EOQ

  param "organization_member_login" {}
}

query "organization_member_repositories_contributed_to_count" {
  sql = <<-EOQ
    select
      repositories_contributed_to_count as "Repositories Contributed To" 
    from 
      github_user 
    where 
      login = $1;
  EOQ

  param "organization_member_login" {}
}

query "organization_member_total_issue_contributions_count" {
  sql = <<-EOQ
    select
      contributions_collection ->> 'TotalIssueContributions' as "Issues Contributed" 
    from 
      github_user 
    where 
      login = $1;
  EOQ

  param "organization_member_login" {}
}

query "organization_member_total_pull_request_contributions_count" {
  sql = <<-EOQ
    select
      contributions_collection ->> 'TotalPullRequestContributions' as "Pull Requests Contributed" 
    from 
      github_user 
    where 
      login = $1;
  EOQ

  param "organization_member_login" {}
}

query "organization_member_total_pull_request_review_contributions_count" {
  sql = <<-EOQ
    select
      contributions_collection ->> 'TotalPullRequestReviewContributions' as "Pull Requests Reviewed" 
    from 
      github_user 
    where 
      login = $1;
  EOQ

  param "organization_member_login" {}
}

query "organization_member_two_factor_authentication_disabled" {
  sql = <<-EOQ
    select
      'Two Factor Authentication' as label,
      case 
        when two_factor_authentication is null then 'Unknown'
        when two_factor_authentication then 'Enabled' 
        else 'Disabled' 
      end as value,
      case 
        when two_factor_authentication is null then 'info'
        when two_factor_authentication then 'ok' 
        else 'alert' 
      end as type
    from 
      github_user 
    where 
      login = $1;
  EOQ

  param "organization_member_login" {}
}

query "organization_member_overview" {
  sql = <<-EOQ
    select
      id as "ID",
      name as "Name",
      type as "Type",
      email as "Email",
      created_at as "Creation Date",
      location as "Location"
    from
      github_user
    where
      login = $1;
  EOQ

  param "organization_member_login" {}
}

query "organization_member_pull_requests_by_repositories" {
  sql = <<-EOQ
    select
      repository_full_name as "Repo",
      state,
      count(*) as total
    from
      github_search_pull_request
    where
      query = 'author:' || $1 || ' org:' || $2
    group by 
      repository_full_name,
      state
    order by 
      total desc
    limit 10;
  EOQ

  param "organization_member_login" {}
  param "organization_login" {}
}

query "organization_member_reviewed_pull_requests_by_repositories" {
  sql = <<-EOQ
    select
      repository_full_name as "Repo",
      state,
      count(*) as total
    from
      github_search_pull_request
    where
      query = 'review-requested:' || $1 || ' org:' || $2
    group by 
      repository_full_name,
      state
    order by 
      total desc
    limit 10;
  EOQ

  param "organization_member_login" {}
  param "organization_login" {}
}

query "organization_member_issues_by_repositories" {
  sql = <<-EOQ
    select
      repository_full_name as "Repo",
      state,
      count(*) as total
    from
      github_search_issue
    where
      query = 'assignee:' || $1 || ' org:' || $2
    group by 
      repository_full_name,
      state
    order by 
      total desc
    limit 10;
  EOQ

  param "organization_member_login" {}
  param "organization_login" {}
}

query "organization_member_commits_by_repositories" {
  sql = <<-EOQ
    select
      repository_full_name as "Repo",
      count(*) as total
    from
      github_search_commit
    where
      query = 'author:' || $1 || ' org:' || $2
    group by 
      repository_full_name
    order by 
      total desc
    limit 10;
  EOQ

  param "organization_member_login" {}
  param "organization_login" {}
}

query "organization_member_contribution_trends" {
  sql = <<-EOQ
    with commit_trend as (
      select
        to_char((commit -> 'author' ->> 'date')::date, 'YYYY-MM') as created_month,
        count(*) as commit_total
      from
        github_search_commit
      where
        query = 'author:' || $1 || ' org:' || $2
      group by 
        created_month
    ), pr_author_trend as (
      select
        to_char(created_at, 'YYYY-MM') as created_month,
        count(*) as pr_author_total
      from
        github_search_pull_request
      where
        query = 'author:' || $1 || ' org:' || $2
      group by 
        created_month
    ), pr_review_trend as (
      select
        to_char(created_at, 'YYYY-MM') as created_month,
        count(*) as pr_review_total
      from
        github_search_pull_request
      where
        query = 'review-requested:' || $1 || ' org:' || $2
      group by 
        created_month
    ), issue_trend as (
      select
        to_char(created_at, 'YYYY-MM') as created_month,
        count(*) as issue_total
      from
        github_search_issue
      where
        query = 'assignee:' || $1 || ' org:' || $2
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

  param "organization_member_login" {}
  param "organization_login" {}
}