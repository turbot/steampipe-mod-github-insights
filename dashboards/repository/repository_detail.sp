dashboard "github_repository_detail" {

  title         = "GitHub Repository Detail"
  documentation = file("./dashboards/repository/docs/repository_detail.md")

  tags = merge(local.repository_common_tags, {
    type = "Detail"
  })

  input "repository_full_name" {
    title = "Select a repository:"
    sql   = query.github_repository_input.sql
    width = 4
  }

  container {

    card {
      width = 2
      query = query.github_repository_visibility
      args = {
        full_name = self.input.repository_full_name.value
      }
    }
    card {
      width = 2
      query = query.github_repository_status
      args = {
        full_name = self.input.repository_full_name.value
      }
    }
    card {
      width = 2
      query = query.github_repository_stargazers
      args = {
        full_name = self.input.repository_full_name.value
      }
    }
    card {
      width = 2
      query = query.github_repository_forks
      args = {
        full_name = self.input.repository_full_name.value
      }
    }
    card {
      width = 2
      query = query.github_repository_subscribers
      args = {
        full_name = self.input.repository_full_name.value
      }
    }

  }

  container {

    table {
      title = "Overview"
      type  = "line"
      width = 3
      query = query.github_repository_overview
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
      title = "Collaborators"
      width = 3
      query = query.github_repository_collaborators
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }

  }

  container {

    table {
      title = "Branches"
      width = 12
      query = query.github_repository_branches
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
      column "repository_full_name" {
        display = "none"
      }
      column "branch_name" {
        display = "none"
      }
      column "Branch Name" {
        href = "${dashboard.github_branch_detail.url_path}?input.repository_full_name={{.repository_full_name | @uri}}&input.branch_name={{.branch_name | @uri}}"
      }
    }

    table {
      title = "Open Issues"
      width = 12
      query = query.github_repository_open_issues
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
  container {

    table {
      title = "Open Pull Requests"
      width = 12
      query = query.github_repository_open_pull_requests
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

query "github_repository_input" {
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

query "github_repository_visibility" {
  sql = <<-EOQ
    select
      'Visibility' as "label",
      visibility as "value"
    from
      github_my_repository
    where
      full_name = $1;
  EOQ

  param "full_name" {}
}

query "github_repository_status" {
  sql = <<-EOQ
    select
      'Status' as "label",
      case
        when disabled then 'disabled'
        else 'enabled'
      end as "value"
    from
      github_my_repository
    where
      full_name = $1;
  EOQ

  param "full_name" {}
}

query "github_repository_stargazers" {
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

query "github_repository_forks" {
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

query "github_repository_subscribers" {
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

query "github_repository_overview" {
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

query "github_repository_branches" {
  sql = <<-EOQ
    select
      name as "Branch Name",
      protected as "Protected",
      name as "branch_name",
      repository_full_name
    from
      github_branch
    where
      repository_full_name = $1
    order by name;
  EOQ

  param "repository_full_name" {}
}

query "github_repository_open_issues" {
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
      repository_full_name = $1 and
      state = 'open'
    order by created_at desc;
  EOQ

  param "repository_full_name" {}
}

query "github_repository_open_pull_requests" {
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
      repository_full_name = $1 and
      state = 'open'
    order by created_at desc;
  EOQ

  param "repository_full_name" {}
}

query "github_repository_collaborators" {
  sql = <<-EOQ
    with internal_collaborators as (
      select
        collaborator.value ->> 0 as "collaborator"
      from
        github_my_repository,
        jsonb_array_elements(collaborator_logins) as collaborator
      where
        full_name = $1
    ), external_collaborators as (
      select
        collaborator.value ->> 0 as "collaborator"
      from
        github_my_repository,
        jsonb_array_elements(outside_collaborator_logins) as collaborator
      where
        full_name = $1
    )

    select collaborator as "Login", 'internal' as "Type" from internal_collaborators
    except
    select collaborator as "Login", 'internal' as "Type" from external_collaborators
    union
    select collaborator as "Login", 'external' as "Type" from external_collaborators;

  EOQ

  param "repository_full_name" {}
}
