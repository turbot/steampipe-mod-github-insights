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
    width = 6

    table {
      title = "Overview"
      type  = "line"
      width = 6
      query = query.github_repository_overview
      args = {
        full_name = self.input.repository_full_name.value
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
