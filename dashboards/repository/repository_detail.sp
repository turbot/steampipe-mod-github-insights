dashboard "repository_detail" {

  title         = "GitHub Repository Detail"
  documentation = file("./dashboards/repository/docs/repository_detail.md")

  tags = merge(local.repository_common_tags, {
    type = "Detail"
  })

  input "repository_full_name" {
    // title = "Select a repository:"
    placeholder = "Select a repository"
    query       = query.repository_input
    width       = 4
  }

  container {

    card {
      width = 2
      query = query.repository_visibility
      args = {
        full_name = self.input.repository_full_name.value
      }
    }

    card {
      width = 2
      query = query.repository_status
      args = {
        full_name = self.input.repository_full_name.value
      }
    }

    card {
      width = 2
      query = query.repository_stargazers
      args = {
        full_name = self.input.repository_full_name.value
      }
    }

    card {
      width = 2
      query = query.repository_forks
      args = {
        full_name = self.input.repository_full_name.value
      }
    }

    card {
      width = 2
      query = query.repository_subscribers
      args = {
        full_name = self.input.repository_full_name.value
      }
    }

    card {
      width = 2
      query = query.repository_security
      args = {
        full_name = self.input.repository_full_name.value
      }
    }

  }

  with "branches_for_repository" {
    query = query.branches_for_repository
    args  = [self.input.repository_full_name.value]
  }

  with "collaborators_for_repository" {
    query = query.collaborators_for_repository
    args  = [self.input.repository_full_name.value]
  }

  container {
    graph {
      title = "Relationships"
      type  = "graph"

      node {
        base = node.repository
        args = {
          repository_full_names = [self.input.repository_full_name.value]
        }
      }

      node {
        base = node.branch
        args = {
          branch_names          = with.branches_for_repository.rows[*].branch_name
          repository_full_names = [self.input.repository_full_name.value]
        }
      }

      node {
        base = node.tag
        args = {
          repository_full_names = [self.input.repository_full_name.value]
        }
      }

      node {
        base = node.user
        args = {
          logins = with.collaborators_for_repository.rows[*].login
        }
      }

      edge {
        base = edge.repository_to_branch
        args = {
          branch_names          = with.branches_for_repository.rows[*].branch_name
          repository_full_names = [self.input.repository_full_name.value]
        }
      }

      edge {
        base = edge.repository_to_tag
        args = {
          repository_full_names = [self.input.repository_full_name.value]
        }
      }

      edge {
        base = edge.repository_to_external_collaborators
        args = {
          repository_full_names = [self.input.repository_full_name.value]
        }
      }

      edge {
        base = edge.repository_to_internal_collaborators
        args = {
          repository_full_names = [self.input.repository_full_name.value]
        }
      }

    }
  }

  container {

    table {
      title = "Overview"
      type  = "line"
      width = 2
      query = query.repository_overview
      args = {
        full_name = self.input.repository_full_name.value
      }
      column "html_url" {
        display = "none"
      }
      column "Repository Name" {
        href = "{{.'html_url'}}"
      }
    }

    container {

      width = 10

      chart {
        title = "Commits by Author"
        type  = "column"
        width = 5
        query = query.commits_by_author
        args = {
          repository_full_name = self.input.repository_full_name.value
        }
      }

      chart {
        title = "Traffic Daily - Last 15 days"
        type  = "line"
        width = 7

        query = query.traffic_past_2week
        args = {
          repository_full_name = self.input.repository_full_name.value
        }
      }

    }

  }

  container {

    input "pull_requests_by_author_login_by_days_input" {
      width = 2
      type  = "text"
      title = "Enter no. of days"
    }

    container {

      chart {
        title = "Pull Requests by Author"
        type  = "column"
        width = 4
        query = query.pull_requests_by_author_login_by_days
        args = {
          repository_full_name = self.input.repository_full_name.value
          time                 = self.input.pull_requests_by_author_login_by_days_input.value
        }
      }

      table {
        title = "Repository Configurations"
        width = 8
        query = query.repository_configurations
        args = {
          repository_full_name = self.input.repository_full_name.value
        }
      }
    }
  }

  container {

    table {
      title = "Open Issues (Last 7 days)"
      width = 12
      query = query.repository_open_issues
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

    table {
      title = "Pull Requests (Last 7 days)"
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

}

query "repository_input" {
  sql = <<-EOQ
    select
      full_name as label,
      full_name as value
    from
      github_my_repository
    order by
      full_name;
  EOQ
}

query "repository_visibility" {
  sql = <<-EOQ
    select
      'Visibility' as "label",
      initcap(visibility) as "value"
    from
      github_my_repository
    where
      full_name = $1;
  EOQ

  param "full_name" {}
}

query "repository_status" {
  sql = <<-EOQ
    select
      'Status' as "label",
      case
        when disabled then 'Disabled'
        else 'Enabled'
      end as "value"
    from
      github_my_repository
    where
      full_name = $1;
  EOQ

  param "full_name" {}
}

query "repository_stargazers" {
  sql = <<-EOQ
    select
      'Stargazers' as "label",
      stargazers_count as "value"
    from
      github_my_repository
    where
      full_name = $1;
  EOQ

  param "full_name" {}
}

query "repository_forks" {
  sql = <<-EOQ
    select
      'Forks' as "label",
      forks_count as "value"
    from
      github_my_repository
    where
      full_name = $1;
  EOQ

  param "full_name" {}
}

query "repository_subscribers" {
  sql = <<-EOQ
    select
      'Subscribers' as "label",
      subscribers_count as "value"
    from
      github_my_repository
    where
      full_name = $1;
  EOQ

  param "full_name" {}
}

query "repository_security" {
  sql = <<-EOQ
    select
      'Security Policy' as "label",
        case when security is null then 'Disabled'
        else 'Enabled'
      end as "value",
        case when security is null then 'alert'
        else 'ok'
      end as "type"
    from
      github_community_profile
    where
      repository_full_name = $1;
  EOQ

  param "full_name" {}
}

query "repository_overview" {
  sql = <<-EOQ
    with protected_branch_array as (
      SELECT 
        ARRAY(select
        name
      from
        github_branch
      where
        repository_full_name = $1
        and protected) as protected_branches,
      $1 as repository_full_name
    )
    select
      full_name as "Repository Name",
      id as "Repository ID",
      description as "Description",
      license_name as "License Name",
      created_at as "Creation date",
      r.updated_at as "Last modified date",
      clone_url as "HTTP Clone URL",
      git_url as "SSH Clone URL",
      html_url,
      case when pb.protected_branches is null then pb.protected_branches::text else 'None' end as "Protected Branches"
    from
      github_my_repository r,
      protected_branch_array pb
    where
      full_name = $1
      and pb.repository_full_name = full_name;
  EOQ

  param "full_name" {}
}

query "repository_open_issues" {
  sql = <<-EOQ
    select
      issue_number as "Issue",
      title as "Title",
      created_at as "Created At",
      author_login as "Author",
      html_url
    from
      github_issue
    where
      repository_full_name = $1
      and state = 'open'
      and created_at >= (current_date - interval '7' day)
    order by created_at desc;
  EOQ

  param "repository_full_name" {}
}

query "repository_configurations" {
  sql = <<-EOQ
    select
      case
        when allow_merge_commit then 'Enabled'
        else 'Disabled'
      end as "Allow Merge Commit",
      case
        when allow_rebase_merge then 'Enabled'
        else 'Disabled'
      end as "Allow Rebase Merge",
      case
        when allow_squash_merge then 'Enabled'
        else 'Disabled'
      end as "Allow Squash Merge",
      case
        when delete_branch_on_merge then 'Enabled'
        else 'Disabled'
      end as "Delete Branch on Merge"
    from
      github_my_repository
    where
      full_name = $1
  EOQ

  param "repository_full_name" {}
}

query "repository_recent_pull_requests" {
  sql = <<-EOQ
    select
      issue_number as "Issue",
      title as "Title",
      created_at as "Created At",
      author_login as "Author",
      changed_files as "Changed Files",
      comments as "Comments",
      commits as "Commits",
      html_url
    from
      github_pull_request
    where
      repository_full_name = $1
      and created_at >= (current_date - interval '7' day)
    order by created_at desc;
  EOQ

  param "repository_full_name" {}
}

// query "repository_collaborators" {
//   sql = <<-EOQ
//     with internal_collaborators as (
//       select
//         collaborator.value ->> 0 as "collaborator"
//       from
//         github_my_repository,
//         jsonb_array_elements(collaborator_logins) as collaborator
//       where
//         full_name = $1
//     ), external_collaborators as (
//       select
//         collaborator.value ->> 0 as "collaborator"
//       from
//         github_my_repository,
//         jsonb_array_elements(outside_collaborator_logins) as collaborator
//       where
//         full_name = $1
//     )

//     select collaborator as "Login", 'internal' as "Type" from internal_collaborators
//     except
//     select collaborator as "Login", 'internal' as "Type" from external_collaborators
//     union
//     select collaborator as "Login", 'external' as "Type" from external_collaborators;

//   EOQ

//   param "repository_full_name" {}
// }

query "branches_for_repository" {
  sql = <<-EOQ
    select
      name as branch_name
    from
      github_branch
    where
      repository_full_name = $1
  EOQ

  param "repository_full_name" {}
}

query "collaborators_for_repository" {
  sql = <<-EOQ
    select
      jsonb_array_elements_text(collaborator_logins) as login
    from
      github_my_repository
    where
      full_name = $1
  EOQ

  param "repository_full_name" {}
}

query "commits_by_author" {
  sql = <<-EOQ
    select
      author_login as "Author",
      count(i.*) as total
    from
      github_commit i
    where
      repository_full_name = $1
      and author_login is not null
    group by 
      author_login
    order by 
      total;
  EOQ

  param "repository_full_name" {}
}

query "traffic_past_2week" {
  sql = <<-EOQ
    select 
      to_char(timestamp, 'DD-MONTH'), 
      count as "Total", 
      uniques as "Unique" 
    from 
      github_traffic_view_daily 
    where 
      repository_full_name = $1 
    order by 
      timestamp
  EOQ

  param "repository_full_name" {}
}

query "pull_requests_by_author_login_by_days" {
  sql = <<-EOQ
    select
      author_login as "author",
      state,
      count(r.*) as total
    from
      github_pull_request r
    where
      repository_full_name = $1
      and (now()::date - created_at::date <= $2 or now()::date - updated_at::date <= $2)
    group by 
      state,
      author_login
    order by 
      total desc;
  EOQ

  param "repository_full_name" {}
  param "time" {}
}

//      with values as (
//  select 
//     timestamp, 
//     count, 
//     'Total' as  total
//   from 
//     github_traffic_view_daily 
//   where repository_full_name = $1

//   union all

//  select 
//     timestamp, 
//     uniques as count,
//     'Uniques' as  total
//   from 
//     github_traffic_view_daily 
//   where repository_full_name = $1
//   order by timestamp
//  ) select
//   *
//   from
//     values
//   group by timestamp, total, count