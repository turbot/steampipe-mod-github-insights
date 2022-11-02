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
      query = query.github_repository_default_branch
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
    }

    table {
      title = "Branches"
      width = 9
      query = query.github_repository_branches
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
      column "commit_url" {
        display = "none"
      }
      column "Commit" {
        href = "{{.'commit_url'}}"
      }
    }

  }

  container {

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

query "github_repository_default_branch" {
  sql = <<-EOQ
    select
      'Default Branch' as "label",
      default_branch as "value"
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
      created_at as "Creation date",
      updated_at as "Last modified date"
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
      commit_sha as "Commit",
      commit_url,
      protected as "Protected"
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
