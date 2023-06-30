dashboard "repository_license_report" {
  title = "GitHub Repository License Report"
  documentation = file("./dashboards/repository/docs/repository_report_license.md")

  tags = merge(local.repository_common_tags, {
    type = "Report"
  })

  container {
    card {
      query = query.repository_count
      width = 2
    }

    card {
      query = query.repository_without_license_count
      width = 2
    }

    card {
      query = query.repository_weak_copyleft_license_count
      width = 2
    }

    card {
      query = query.repository_popular_copyleft_license_count
      width = 2
    }

    card {
      query = query.repository_permissive_license_count
      width = 2
    }

    card {
      query = query.repository_other_license_count
      width = 2
    }
  }

  container {
    table {
      title = "Repository Licenses"
      query = query.repository_license_table

      column "url" {
        display = "none"
      }

      column "Repository" {
        href = "{{.'url'}}"
      }
    }
  }
}

query "repository_without_license_count" {
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

query "repository_mpl_license_count" {
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

query "repository_gpl_license_count" {
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

query "repository_apache_license_count" {
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

query "repository_mit_license_count" {
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

query "repository_weak_copyleft_license_count" {
  sql = <<-EOQ
    select
      'Weak Copyleft' as label, 
      count(*) as value
    from 
      github_my_repository 
    where 
      license_info ->> 'key' in ('lgpl-3.0','lgpl-2.1','mpl-2.0','epl-2.0','osl-3.0','eupl-3.0')
    group by
      license_info;
  EOQ
}

query "repository_popular_copyleft_license_count" {
  sql = <<-EOQ
    select
      'Popular Copyleft' as label, 
      count(*) as value
    from 
      github_my_repository 
    where 
      license_info ->> 'key' in ('gpl-3.0','gpl-2.0','agpl-3.0','agpl-2.0','cc-by-sa-4.0','apsl')
    group by
      license_info;
  EOQ
}

query "repository_permissive_license_count" {
  sql = <<-EOQ
    select
      'Permissive' as label, 
      count(*) as value
    from 
      github_my_repository 
    where 
      license_info ->> 'key' in ('apache-2.0','mit','bsd-3','bsd-2','bsd-3-clause','bsd2-clause', 'cc-by-4.0', 'wtfpl', 'ms-pl', 'unlicensed')
    group by
      license_info;
  EOQ
}

query "repository_other_license_count" {
  sql = <<-EOQ
    select
      'Other' as label, 
      count(*) as value
    from 
      github_my_repository 
    where 
      license_info is not null
    and
      license_info ->> 'key' not in ('lgpl-3.0','lgpl-2.1','mpl-2.0','epl-2.0','osl-3.0','eupl-3.0','gpl-3.0','gpl-2.0','agpl-3.0','agpl-2.0','cc-by-sa-4.0','apsl','apache-2.0','mit','bsd-3','bsd-2','bsd-3-clause','bsd2-clause', 'cc-by-4.0', 'wtfpl', 'ms-pl', 'unlicensed')
    group by
      license_info;
  EOQ
}

query "repository_license_table" {
  sql = <<-EOQ
    select
      name_with_owner as "Repository",
      license_info ->> 'key' as "License",
      license_info ->> 'name' as "License Name",
      case
        when (license_info ->> 'key' in ('lgpl-3.0','lgpl-2.1','mpl-2.0','epl-2.0','osl-3.0','eupl-3.0')) then 'weak copyleft'
        when (license_info ->> 'key' in ('gpl-3.0','gpl-2.0','agpl-3.0','agpl-2.0','cc-by-sa-4.0','apsl')) then 'popular copyleft'
        when (license_info ->> 'key' in ('apache-2.0','mit','bsd-3','bsd-2','bsd-3-clause','bsd2-clause', 'cc-by-4.0', 'wtfpl', 'ms-pl', 'unlicensed')) then 'permissive'
        when (license_info ->> 'key' is null) then null
        else 'other'
      end as "License Type",
      url
    from
      github_my_repository
    order by
      "License";
  EOQ
}
