dashboard "issue_open_report" {

  title         = "GitHub Open Issue Report"
  documentation = file("./dashboards/issue/docs/issue_open_report.md")

  tags = merge(local.issue_common_tags, {
    type = "Report"
  })

  input "repository_full_name" {
    title = "Select a repository:"
    query = query.repository_input
    width = 4
  }

  container {
    table {
      title = "Open Issues"
      query = query.open_issues
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
      column "html_url" {
        display = "none"
      }
      column "Number" {
        href = "{{.'html_url'}}"
      }
    }
  }
}

// TODO: Format and uncomment commented columns
query "open_issues" {
  sql = <<-EOQ
    select
      issue_number as "Number",
      substring(title for 100) as "Title",
      author_login as "Author",
      assignee_logins as "Assignees",
      author_association as "Author Association",
      substring(body for 100) as "Body",
      comments as "Comments",
      created_at as "Created At",
      updated_at as "Updated At",
      html_url as "html_url",
      --labels as "Labels",
      locked as "Locked",
      milestone_title as "Milestone"
      --reactions as "Reactions",
      --tags as "Tags"
    from
      github_issue, jsonb_array_elements(assignee_logins) as assignees
    where
      repository_full_name = $1 and
      state = 'open'
    order by issue_number desc;
  EOQ

  param "repository_full_name" {}
}
