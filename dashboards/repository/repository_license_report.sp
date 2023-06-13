dashboard "repository_license_report" {
  title = "GitHub Repository License Report"
  documentation = file("./dashboards/repository/docs/repository_license_report.md")

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

    card {
      query = query.repositories_mpl_license_count
      width = 2
    }

    card {
      query = query.repositories_gpl_license_count
      width = 2
    }

    card {
      query = query.repositories_apache_license_count
      width = 2
    }

    card {
      query = query.repositories_mit_license_count
      width = 2
    }
  }

  container {
    table {
      title = "Repository Licenses"
      query = query.repositories_license_table

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

query "repositories_mpl_license_count" {
  sql = <<-EOQ
    select
      license_info ->> 'key' as label, 
      count(*) as value
    from 
      github_my_repository 
    where 
      license_info ->> 'key' = 'mpl-2.0'
    group by
      license_info;
  EOQ
}

query "repositories_gpl_license_count" {
  sql = <<-EOQ
    select
      'gpl-3.0 / agpl-3.0 / lgpl-3.0' as label, 
      count(*) as value
    from 
      github_my_repository 
    where 
      license_info ->> 'key' IN ('gpl-3.0', 'agpl-3.0', 'lgpl-3.0')
    group by
      license_info;
  EOQ
}

query "repositories_apache_license_count" {
  sql = <<-EOQ
    select
      license_info ->> 'key' as label, 
      count(*) as value
    from 
      github_my_repository 
    where 
      license_info ->> 'key' = 'apache-2.0'
    group by
      license_info;
  EOQ
}

query "repositories_mit_license_count" {
  sql = <<-EOQ
    select
      license_info ->> 'key' as label, 
      count(*) as value
    from 
      github_my_repository 
    where 
      license_info ->> 'key' = 'mit'
    group by
      license_info;
  EOQ
}

query "repositories_license_table" {
  sql = <<-EOQ
    select
      name_with_owner as "Repository",
      license_info ->> 'key' as "License",
      license_info ->> 'name' as "License Name",
      url
    from
      github_my_repository;
  EOQ
}
