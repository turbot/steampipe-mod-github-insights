dashboard "repository_license_report" {
  title = "GitHub Repository License Report"
  documentation = file("./dashboards/repository/docs/repository_license_report.md")

  tags = merge(local.repository_common_tags, {
    type = "Report"
  })

  container {
    card {
      query = query.repositories_without_license_count
      width = 2
    }
  }

  container {
    table {
      title = "Repository Licenses"
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
      case
        when license_info is null then 'Not Set'
        else license_info ->> 'name'
      end as "License",
      url
    from
      github_my_repository;
  EOQ
}
