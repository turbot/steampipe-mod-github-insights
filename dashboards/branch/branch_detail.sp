dashboard "github_branch_detail" {

  title         = "GitHub Branch Detail"
  documentation = file("./dashboards/branch/docs/branch_detail.md")

  tags = merge(local.branch_common_tags, {
    type = "Detail"
  })

  input "repository_full_name" {
    title = "Select a repository:"
    sql   = query.github_repository_input.sql
    width = 4
  }
  input "branch_name" {
    title = "Select a branch:"
    query   = query.github_branch_input
    width = 4
    args = {
      repository_full_name = self.input.repository_full_name.value
    }
  }

  container {

    table {
      title = "Overview"
      type  = "line"
      width = 3
      query = query.github_branch_overview
      args = {
        repository_full_name = self.input.repository_full_name.value
        branch_name = self.input.branch_name.value
      }
    }

  }

}

query "github_branch_input" {
  sql = <<-EOQ
    select
      name as label,
      name as value
    from
      github_branch
    where
      repository_full_name = $1
    order by
      name;
  EOQ

  param "repository_full_name" {}
}

query "github_branch_overview" {
  sql = <<-EOQ
    select
      repository_full_name as "Repository",
      name as "Branch",
      protected as "Protected"
    from
      github_branch
    where
      repository_full_name = $1 and
      name = $2;
  EOQ

  param "repository_full_name" {}
  param "branch_name" {}
}