dashboard "pull_request_detail" {
  title         = "GitHub Pull Request Detail"
  documentation = file("./dashboards/pullrequest/docs/pull_request_detail.md")

  tags = merge(local.pull_request_common_tags, {
    type = "Detail"
  })

  input "repository_full_name" {
    title = "Select a repository:"
    query = query.repository_input
    width = 4
  }

  input "pull_request_id" {
    title = "Select a pull request:"
    query = query.pull_request_input
    width = 6
    args = {
      repository_full_name = self.input.repository_full_name.value
    }
  }

  container {

    card {
      width = 2
      query = query.pull_request_commits
      args = {
        repository_full_name = self.input.repository_full_name.value
        pull_request_id      = self.input.pull_request_id.value
      }
    }

    card {
      width = 2
      query = query.pull_request_changed_files
      args = {
        repository_full_name = self.input.repository_full_name.value
        pull_request_id      = self.input.pull_request_id.value
      }
    }

    card {
      width = 2
      query = query.pull_request_additions
      args = {
        repository_full_name = self.input.repository_full_name.value
        pull_request_id      = self.input.pull_request_id.value
      }
    }

    card {
      width = 2
      query = query.pull_request_deletions
      args = {
        repository_full_name = self.input.repository_full_name.value
        pull_request_id      = self.input.pull_request_id.value
      }
    }
  }

  with "users_for_pull_request" {
    query = query.users_for_pull_request
    args = {
      repository_full_name = self.input.repository_full_name.value
      pull_request_id      = self.input.pull_request_id.value
    }
  }

  with "commits_for_pull_request" {
    query = query.commits_for_pull_request
    args = {
      repository_full_name = self.input.repository_full_name.value
      pull_request_id      = self.input.pull_request_id.value
    }
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
        base = node.pull_request
        args = {
          repository_full_name = self.input.repository_full_name.value
          pull_request_ids     = [self.input.pull_request_id.value]
        }
      }

      node {
        base = node.user
        args = {
          logins = with.users_for_pull_request.rows[*].login
        }
      }

      node {
        base = node.commit
        args = {
          commit_sha           = with.commits_for_pull_request.rows[*].commit_sha
          repository_full_name = self.input.repository_full_name.value
        }
      }

      edge {
        base = edge.pull_request_to_commit
        args = {
          repository_full_names = [self.input.repository_full_name.value]
          pull_request_ids      = [self.input.pull_request_id.value]
        }
      }

      edge {
        base = edge.repository_to_pull_request
        args = {
          repository_full_names = self.input.repository_full_name.value
          pull_request_ids      = [self.input.pull_request_id.value]
        }
      }

      edge {
        base = edge.pull_request_to_reviewer
        args = {
          repository_full_names = self.input.repository_full_name.value
          pull_request_ids      = [self.input.pull_request_id.value]
        }
      }

      edge {
        base = edge.pull_request_to_assignee
        args = {
          repository_full_names = self.input.repository_full_name.value
          pull_request_ids      = [self.input.pull_request_id.value]
        }
      }
    }
  }

  container {

    table {
      title = "Overview"
      type  = "line"
      width = 3
      query = query.pull_request_overview
      args = {
        repository_full_name = self.input.repository_full_name.value
        pull_request_id      = self.input.pull_request_id.value
      }
    }

    table {
      title = "Tags"
      width = 3
      query = query.pull_request_tags
      args = {
        repository_full_name = self.input.repository_full_name.value
        pull_request_id      = self.input.pull_request_id.value
      }
    }

    table {
      title = "Labels"
      width = 6
      query = query.pull_request_labels
      args = {
        repository_full_name = self.input.repository_full_name.value
        pull_request_id      = self.input.pull_request_id.value
      }
    }
  }

  container {

    table {
      title = "Requested Reviewers"
      query = query.pull_request_reviewers
      args = {
        repository_full_name = self.input.repository_full_name.value
        pull_request_id      = self.input.pull_request_id.value
      }
    }

  }

}

query "pull_request_input" {
  sql = <<-EOQ
    select
      concat(issue_number, ' ', title) as label,
      issue_number as value
    from
      github_pull_request
    where
      repository_full_name = $1
      and state <> 'closed'
    order by
      issue_number;
  EOQ

  param "repository_full_name" {}
}

query "pull_request_commits" {
  sql = <<-EOQ
    select
      'Commits' as label,
      commits as value
    from
      github_pull_request
    where
      repository_full_name = $1 and
      issue_number = $2;
  EOQ

  param "repository_full_name" {}
  param "pull_request_id" {}
}

query "pull_request_changed_files" {
  sql = <<-EOQ
    select
      'Changed Files' as label,
      changed_files as value
    from
      github_pull_request
    where
      repository_full_name = $1 and
      issue_number = $2;
  EOQ

  param "repository_full_name" {}
  param "pull_request_id" {}
}

query "pull_request_additions" {
  sql = <<-EOQ
    select
      'Additions' as label,
      additions as value
    from
      github_pull_request
    where
      repository_full_name = $1 and
      issue_number = $2;
  EOQ

  param "repository_full_name" {}
  param "pull_request_id" {}
}

query "pull_request_deletions" {
  sql = <<-EOQ
    select
      'Deletions' as label,
      deletions as value
    from
      github_pull_request
    where
      repository_full_name = $1 and
      issue_number = $2;
  EOQ

  param "repository_full_name" {}
  param "pull_request_id" {}
}

query "pull_request_overview" {
  sql = <<-EOQ
    select
      author_login as "Author Login",
      case 
        when draft then 'Enabled' else 'Disabled' 
      end as "Draft State",
      mergeable_state as "Mergeable State",
      created_at as "Created At",
      updated_at as "Updated At",
      review_comments as "Total Review Comments",
      html_url as "URL"
    from
      github_pull_request
    where
      repository_full_name = $1 and
      issue_number = $2;
  EOQ

  param "repository_full_name" {}
  param "pull_request_id" {}
}

query "pull_request_labels" {
  sql = <<-EOQ
    select
      l ->> 'name' as "Name",
      l ->> 'id' as "ID",
      l ->> 'default' as "Default",
      l ->> 'description' as "Description",
      l ->> 'color' as "Color",
      l ->> 'node_id' as "Node ID",
      l ->> 'url' as "URL"
    from
      github_pull_request,
      jsonb_array_elements(labels) as l
    where
      repository_full_name = $1
      and issue_number = $2
  EOQ

  param "repository_full_name" {}
  param "pull_request_id" {}
}

query "pull_request_tags" {
  sql = <<-EOQ
    with jsondata as (
      select
        tags::json as tags
      from
        github_pull_request
      where
        repository_full_name = $1
        and issue_number = $2
    )
    select
      key as "Key",
      value as "Value"
    from
      jsondata,
      json_each_text(tags)
    order by
      key;
  EOQ

  param "repository_full_name" {}
  param "pull_request_id" {}
}

query "pull_request_reviewers" {
  sql = <<-EOQ
    select
      u.login as "Login",
      u.name as "Name",
      u.id as "ID",
      u.node_id as "Node ID",
      u.site_admin as "Site Admin",
      u.type as "Type",
      u.created_at as "Created At",
      u.html_url as "HTML URL",
      u.avatar_url as "Avatar URL"
    from
      github_pull_request,
      jsonb_array_elements_text(requested_reviewer_logins) as l
      left join github_user as u on u.login = l
    where
      repository_full_name = $1
      and issue_number = $2
  EOQ

  param "repository_full_name" {}
  param "pull_request_id" {}
}

query "users_for_pull_request" {
  sql = <<-EOQ
    select
      u.login as login
    from
      github_pull_request,
      jsonb_array_elements_text(requested_reviewer_logins) as r
      left join github_user as u on u.login = r
    where
      repository_full_name = $1
      and issue_number = $2
    union
    select
      u.login as login
    from
      github_pull_request,
      jsonb_array_elements_text(assignee_logins) as a
      left join github_user as u on u.login = a
    where
      repository_full_name = $1
      and issue_number = $2
  EOQ

  param "repository_full_name" {}
  param "pull_request_id" {}
}

query "commits_for_pull_request" {
  sql = <<-EOQ
    select
      merge_commit_sha as commit_sha
    from
      github_pull_request
    where
      repository_full_name = $1
      and issue_number = $2
  EOQ

  param "repository_full_name" {}
  param "pull_request_id" {}
}
