dashboard "repository_security_advisory_report" {
  title = "GitHub Repositories Security Advisory Report"
  documentation = file("./dashboards/repository/docs/repository_security_advisory_report.md")

  tags = merge(local.repository_common_tags, {
    type = "Report"
  })

  container {
    card {
      query = query.repository_security_advisory_count
      width = 2
    }

    card {
      query = query.repository_security_advisory_low_count
      width = 2
    }

    card {
      query = query.repository_security_advisory_medium_count
      width = 2
    }

    card {
      query = query.repository_security_advisory_high_count
      width = 2
    }
  }

  container {
    table {
      title = "Open Security Advisories"
      query = query.repository_security_advisory_table

      column "url" {
        display = "none"
      }

      column "advisory_url" {
        display = "none"
      }

      column "Repository" {
        href = "{{.'url'}}"
      }

      column "CVE" {
        href = "{{.'advisory_url'}}"
      } 
    }
  }
}

query "repository_security_advisory_count" {
  sql = <<-EOQ
    select
      'Open Advisories' as label,
      count(*) as value,
      'info' as type
    from
      github_my_repository r
    join
      github_repository_dependabot_alert a
    on
      r.name_with_owner = a.repository_full_name
    where
      a.state = 'open';
  EOQ
}

query "repository_security_advisory_low_count" {
  sql = <<-EOQ
    select
      'Low Severity' as label,
      count(*) as value,
      'info' as type
    from
      github_my_repository r
    join
      github_repository_dependabot_alert a
    on
      r.name_with_owner = a.repository_full_name
    where
      a.state = 'open'
    and a.security_advisory_severity = 'low';
  EOQ
}

query "repository_security_advisory_medium_count" {
  sql = <<-EOQ
    select
      'Medium Severity' as label,
      count(*) as value,
      case
        when count(*) > 0 then 'alert'
        else 'ok'
      end as type
    from
      github_my_repository r
    join
      github_repository_dependabot_alert a
    on
      r.name_with_owner = a.repository_full_name
    where
      a.state = 'open'
    and a.security_advisory_severity = 'medium';
  EOQ
}

query "repository_security_advisory_high_count" {
  sql = <<-EOQ
    select
      'High Severity' as label,
      count(*) as value,
      case
        when count(*) > 0 then 'alert'
        else 'ok'
      end as type
    from
      github_my_repository r
    join
      github_repository_dependabot_alert a
    on
      r.name_with_owner = a.repository_full_name
    where
      a.state = 'open'
    and a.security_advisory_severity = 'high';
  EOQ
}

query "repository_security_advisory_table" {
  sql = <<-EOQ
    select
      r.name_with_owner as "Repository",
      a.state as "State",
      a.security_advisory_cve_id as "CVE",
      a.security_advisory_severity as "Severity",
      a.dependency_package_name as "Package",
      a.dependency_scope as "Scope",
      a.created_at as "Alert Created",
      age(now()::date, a.created_at::date) as "Alert Age",
      a.html_url as "advisory_url",
      r.url
    from
      github_my_repository r
    join
      github_repository_dependabot_alert a
    on
      r.name_with_owner = a.repository_full_name
    where
      a.state = 'open';
  EOQ
}