dashboard "repository_release_report" {

  title         = "GitHub Repository Release Report"
  documentation = file("./dashboards/repository/docs/repository_release_report.md")

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
      query = query.repository_release_count
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }
  }

  container {
    table {
      title = "Releases"
      query = query.repository_release_report
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }
  }
}

query "repository_release_count" {
  sql = <<-EOQ
    select
      count(*) as "Releases"
    from
      github_release
    where
      repository_full_name = $1;
  EOQ

  param "repository_full_name" {}
}

query "repository_release_report" {
  sql = <<-EOQ
    select
      name as "Name",
      author_login as "Author Login",
      tag_name as "Tag Name",
      draft as "Draft",
      prerelease as "Prerelease",
      created_at as "Created At",
      published_at as "Published At",
      upload_url as "Upload URL",
      tarball_url as "Tarball URL",
      zipball_url as "Zipball URL",
      assets_url as "Assets URL"
    from
      github_release
    where
      repository_full_name = $1
    order by
      created_at desc;
  EOQ

  param "repository_full_name" {}
}
 