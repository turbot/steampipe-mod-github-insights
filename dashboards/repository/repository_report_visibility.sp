dashboard "repository_visibility_report" {
  title = "GitHub Repository Visibility Report"
  documentation = file("./dashboards/repository/docs/repository_report_visibility.md")

  tags = merge(local.repository_common_tags, {
    type = "Report"
  })

  container {
    card {
      query = query.repository_count
      width = 2
    }

    card {
      query = query.repository_public_count
      width = 2
    }

    card {
      query = query.repository_private_count
      width = 2
    }
  }

  container {
    table {
      title = "Repository Visibility"
      query = query.repository_visibility_table

      column "url" {
        display = "none"
      }

      column "Repository" {
        href = "{{.'url'}}"
      }
    }
  }
}

query "repository_public_count" {
  sql = <<-EOQ
    select
      'Public' as label,
      count(*) as value,
      case
        when count(*) > 0 then 'alert'
        else 'ok'
      end as type
    from
      github_my_repository
    where
      visibility = 'PUBLIC';
  EOQ
}

query "repository_private_count" {
  sql = <<-EOQ
    select
      'Private' as label,
      count(*) as value
    from
      github_my_repository
    where
      visibility = 'PRIVATE';
  EOQ
}

query "repository_visibility_table" {
  sql = <<-EOQ
    select
      name_with_owner as "Repository",
      visibility as "Visibility",
      url
    from
      github_my_repository
    order by
      visibility, name_with_owner;
  EOQ
}