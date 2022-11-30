dashboard "github_pull_request_detail" {
  title = "GitHub Pull Request Detail"
  # documentation = file("./dashboards/pull_request/docs/pull_request_detail.md")

  tags = merge(local.pull_request_common_tags, {
    type = "Detail"
  })

  input "repository_full_name" {
    title = "Select a repository:"
    query = query.github_repository_input
    width = 4
  }

  input "pull_request_id" {
    title = "Select a pull request:"
    query = query.github_pull_request_input
    width = 6
    args = {
      repository_full_name = self.input.repository_full_name.value
    }
  }

  container {

    card {
      width = 2
      query = query.github_pull_request_commits
      args = {
        repository_full_name = self.input.repository_full_name.value
        pull_request_id      = self.input.pull_request_id.value
      }
    }

    card {
      width = 2
      query = query.github_pull_request_changed_files
      args = {
        repository_full_name = self.input.repository_full_name.value
        pull_request_id      = self.input.pull_request_id.value
      }
    }

    card {
      width = 2
      query = query.github_pull_request_additions
      args = {
        repository_full_name = self.input.repository_full_name.value
        pull_request_id      = self.input.pull_request_id.value
      }
    }

    card {
      width = 2
      query = query.github_pull_request_deletions
      args = {
        repository_full_name = self.input.repository_full_name.value
        pull_request_id      = self.input.pull_request_id.value
      }
    }


    card {
      width = 2
      query = query.github_pull_request_author_association
      args = {
        repository_full_name = self.input.repository_full_name.value
        pull_request_id      = self.input.pull_request_id.value
      }
    }
  }

  container {

    table {
      title = "Overview"
      type  = "line"
      width = 3
      query = query.github_pull_request_overview
      args = {
        repository_full_name = self.input.repository_full_name.value
        pull_request_id      = self.input.pull_request_id.value
      }
    }
  }

}

query "github_pull_request_input" {
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

query "github_pull_request_commits" {
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

query "github_pull_request_changed_files" {
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

query "github_pull_request_additions" {
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

query "github_pull_request_deletions" {
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

query "github_pull_request_author_association" {
  sql = <<-EOQ
    select
      'Author Association' as label,
      author_association as value
    from
      github_pull_request
    where
      repository_full_name = $1 and
      issue_number = $2;
  EOQ

  param "repository_full_name" {}
  param "pull_request_id" {}
}

query "github_pull_request_overview" {
  sql = <<-EOQ
    select
      author_login as "Author Login",
      author_association as "Author Association",
      jsonb_array_elements_text(assignee_logins) as "Assignee Logins",
      changed_files as "Changed Files",
      commits as "Commits",
      created_at as "Created At",
      draft as "Draft",
      html_url as "URL",
      labels as "Labels",
      mergeable_state as "Mergeable State",
      requested_reviewer_logins as "Reviewer Login",
      review_comments as "Review Comments",
      tags as "Tags",
      updated_at as "Updated At"
    from
      github_pull_request
    where
      repository_full_name = $1 and
      issue_number = $2;
  EOQ

  param "repository_full_name" {}
  param "pull_request_id" {}
}
