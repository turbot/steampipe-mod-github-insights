dashboard "repository_detail" {

  title         = "GitHub Repository Detail"
  documentation = file("./dashboards/repository/docs/repository_detail.md")

  tags = merge(local.repository_common_tags, {
    type = "Detail"
  })

  input "repository_full_name" {
    title = "Select a repository:"
    query = query.repository_input
    width = 4
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
      width = 3
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

    table {
      title = "License Detail"
      width = 3
      query = query.repository_license
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }

    table {
      title = "Protected Branches"
      width = 6
      query = query.repository_branches
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
      column "repository_full_name" {
        display = "none"
      }
      column "Branch Name" {
        href = "${dashboard.branch_detail.url_path}?input.repository_full_name={{.repository_full_name | @uri}}&input.branch_name={{.branch_name | @uri}}"
      }
    }

  }

  container {

    title = "Analysis"

    container {

      chart {
        title = "Pull Requests by State"
        type  = "column"
        width = 4
        query = query.pull_requests_by_state
        args = {
          repository_full_name = self.input.repository_full_name.value
        }
      }

      chart {
        title = "Pull Requests by Author Association"
        type  = "column"
        width = 4
        query = query.pull_requests_by_author_association
        args = {
          repository_full_name = self.input.repository_full_name.value
        }
      }

      chart {
        title = "Pull Requests by Author"
        type  = "column"
        width = 4
        query = query.pull_requests_by_author_login
        args = {
          repository_full_name = self.input.repository_full_name.value
        }
      }
    }

    container {

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
        title = "Issues by Author Association"
        type  = "column"
        width = 4
        query = query.issues_by_author_association
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
    }

    container {

      chart {
        title = "Commits by Author"
        type  = "column"
        width = 4
        query = query.commits_by_author
        args = {
          repository_full_name = self.input.repository_full_name.value
        }
      }

      chart {
        title = "Traffic Daily - Last 15 days"
        type  = "line"
        width = 6

        query = query.traffic_past_2week
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
      title = "Open Pull Requests (Last 7 days)"
      width = 12
      query = query.repository_open_pull_requests
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
    select
      full_name as "Repository Name",
      id as "Repository ID",
      description as "Description",
      clone_url as "HTTP Clone URL",
      git_url as "SSH Clone URL",
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
      created_at as "Creation date",
      updated_at as "Last modified date",
      html_url
    from
      github_my_repository
    where
      full_name = $1;
  EOQ

  param "full_name" {}
}

query "repository_license" {
  sql = <<-EOQ
    select
      license ->> 'name' as "License Name",
      license ->> 'key' as "License Key"
    from
      github_community_profile
    where
      repository_full_name = $1;
  EOQ

  param "repository_full_name" {}
}

query "repository_branches" {
  sql = <<-EOQ
    select
      name as "Branch Name",
      protected as "Protected",
      repository_full_name
    from
      github_branch
    where
      repository_full_name = $1
      and protected
    order by name;
  EOQ

  param "repository_full_name" {}
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
      and created_at >= (current_date - interval '7' day);
    order by created_at desc;
  EOQ

  param "repository_full_name" {}
}

query "repository_open_pull_requests" {
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
      and state = 'open'
      and created_at >= (current_date - interval '7' day);
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

query "pull_requests_by_state" {
  sql = <<-EOQ
    select
      state as "State",
      count(r.*) as total
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

query "pull_requests_by_author_association" {
  sql = <<-EOQ
    select
      author_association as "author association",
      count(r.*) as total
    from
      github_pull_request r
    where
      repository_full_name = $1
    group by 
      author_association
    order by 
      author_association;
  EOQ

  param "repository_full_name" {}
}

query "pull_requests_by_author_login" {
  sql = <<-EOQ
    select
      author_login as "author",
      count(r.*) as total
    from
      github_pull_request r
    where
      repository_full_name = $1
    group by 
      author_login
    order by 
      total;
  EOQ

  param "repository_full_name" {}
}

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

query "issues_by_author_association" {
  sql = <<-EOQ
    select
      author_association as "author association",
      count(i.*) as total
    from
      github_issue i
    where
      repository_full_name = $1
    group by 
      author_association
    order by 
      author_association;
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