dashboard "repository_without_license_report" {
  title = "GitHub Repositories Without License Report"
  documentation = file("./dashboards/repository/docs/repository_unlicensed_report.md")

  tags = merge(local.repository_common_tags, {
    type = "Report"
  })

  container {
    card {
      query = query.repository_count
      width = 2
    }

    card {
      query = query.repositories_without_license_count
      width = 2
    }
  }

  container {
    table {
      title = "Repositories without a license"
      query = query.repositories_without_license_table

      column "url" {
        display = "none"
      }

      column "Repository" {
        href = "{{.'url'}}"
      }
    }
  }
}

query "repositories_without_license_count" {
  sql = <<-EOQ
    select
      'Without License' as label,
      count(*) as value,
      case
        when count(*) > 0 then 'alert'
        else 'ok'
      end as type
    from 
      github_my_repository 
    where 
      license_info is null;
  EOQ
}

query "repositories_without_license_table" {
  sql = <<-EOQ
    select
      name_with_owner as "Repository",
      url
    from
      github_my_repository
    where
      license_info is null;
  EOQ
}

