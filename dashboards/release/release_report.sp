dashboard "release_report" {

  title         = "GitHub Release Report"
  documentation = file("./dashboards/release/docs/release_report.md")

  tags = merge(local.release_common_tags, {
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
      prerelease as "Pre-release",
      created_at as "Creation Date",
      published_at as "Published At",
      tarball_url as "Download Tar URL",
      zipball_url as "Download Zip URL"
    from
      github_release
    where
      repository_full_name = $1
    order by
      created_at desc;
  EOQ

  param "repository_full_name" {}
}
 