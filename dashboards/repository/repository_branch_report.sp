dashboard "repository_branch_report" {

  title         = "GitHub Repository Branch Report"
  documentation = file("./dashboards/repository/docs/repository_branch_report.md")

  tags = merge(local.repository_common_tags, {
    type = "Report"
  })

  input "repository_full_name" {
    // title       = "Select a repository:"
    placeholder = "Select a repository"
    query       = query.repository_input
    width       = 4
  }

  container {

    card {
      width = 2
      query = query.repository_branch_count
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }
  }

  container {
    table {
      title = "Branches"
      query = query.repository_branch_report
      args = {
        repository_full_name = self.input.repository_full_name.value
      }

      column "commit_url" {
        display = "none"
      }
      # column "Number" {
      #   href = "{{.'html_url'}}"
      # }
    }
  }
}

query "repository_branch_count" {
  sql = <<-EOQ
    select
      count(*) as "Branches"
    from
      github_branch
    where
      repository_full_name = $1;
  EOQ

  param "repository_full_name" {}
}

query "repository_branch_report" {
  sql = <<-EOQ
    select
      t.name as "Name",
      t.commit_sha as "Commit SHA",
      c.author_date as "Author Date",
      t.protected as "Protected",
      c.message as "Commit Message",
      t.commit_url
    from
      github_branch as t
      left join github_commit as c
        on t.commit_sha = c.sha
        and c.repository_full_name = t.repository_full_name
    where
      t.repository_full_name = $1
    order by
      protected desc,
      c.author_date desc;
  EOQ

  param "repository_full_name" {}
}
 