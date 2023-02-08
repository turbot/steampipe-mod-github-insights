dashboard "repository_stargazer_report" {

  title         = "GitHub Repository Stargazer Report"
  documentation = file("./dashboards/issue/docs/issue_open_report.md")

  tags = merge(local.repository_common_tags, {
    type = "Report"
  })

  input "repository_full_name" {
    title = "Select a repository:"
    query = query.repository_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.repository_stargazer_count
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }
  }

  container {
    table {
      title = "Stars"
      query = query.repository_stargazer_report
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
      # column "html_url" {
      #   display = "none"
      # }
      # column "Number" {
      #   href = "{{.'html_url'}}"
      # }
    }
  }
}

query "repository_stargazer_count" {
  sql = <<-EOQ
    select
      count(*) as "Stars"
    from
      github_stargazer
    where
      repository_full_name = $1;
  EOQ

  param "repository_full_name" {}
}

query "repository_stargazer_report" {
  sql = <<-EOQ
    select
      repository_full_name as "Repository Full Name",
      starred_at as "Starred At",
      user_login as "User Login"
    from
      github_stargazer
    where
      repository_full_name = $1
    order by
      starred_at desc;
  EOQ

  param "repository_full_name" {}
}
 