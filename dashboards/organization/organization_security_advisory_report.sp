dashboard "organization_security_advisory_report" {
  title = "GitHub Organization Security Advisory Report"
  documentation = file("./dashboards/organization/docs/organization_security_advisory_report.md")

  tags = merge(local.organization_common_tags, {
    type = "Report"
  })

  container {
    card {
      query = query.organization_security_advisory_count
      width = 2
    }

    card {
      query = query.organization_security_advisory_low_count
      width = 2
    }

    card {
      query = query.organization_security_advisory_medium_count
      width = 2
    }

    card {
      query = query.organization_security_advisory_high_count
      width = 2
    }
  }

  container {
    table {
      title = "Open Security Advisories"
      query = query.organization_security_advisory_table

      column "url" {
        display = "none"
      }

      column "advisory_url" {
        display = "none"
      }

      column "Organization" {
        href = "{{.'url'}}"
      }

      column "CVE" {
        href = "{{.'advisory_url'}}"
      } 
    }
  }
}

query "organization_security_advisory_count" {
  sql = <<-EOQ
    select
      'Open Advisories' as label,
      count(*) as value,
      'info' as type
    from
      github_my_organization o
    join
      github_organization_dependabot_alert a
    on
      o.login = a.organization
    where
      a.state = 'open';
  EOQ
}

query "organization_security_advisory_low_count" {
  sql = <<-EOQ
    select
      'Low Severity' as label,
      count(*) as value,
      'info' as type
    from
      github_my_organization o
    join
      github_organization_dependabot_alert a
    on
      o.login = a.organization
    where
      a.state = 'open'
    and a.security_advisory_severity = 'low';
  EOQ
}

query "organization_security_advisory_medium_count" {
  sql = <<-EOQ
    select
      'Medium Severity' as label,
      count(*) as value,
      case
        when count(*) > 0 then 'alert'
        else 'ok'
      end as type
    from
      github_my_organization o
    join
      github_organization_dependabot_alert a
    on
      o.login = a.organization
    where
      a.state = 'open'
    and a.security_advisory_severity = 'medium';
  EOQ
}

query "organization_security_advisory_high_count" {
  sql = <<-EOQ
    select
      'High Severity' as label,
      count(*) as value,
      case
        when count(*) > 0 then 'alert'
        else 'ok'
      end as type
    from
      github_my_organization o
    join
      github_organization_dependabot_alert a
    on
      o.login = a.organization
    where
      a.state = 'open'
    and a.security_advisory_severity = 'high';
  EOQ
}

query "organization_security_advisory_table" {
  sql = <<-EOQ
    select
      o.login as "Organization",
      a.state as "State",
      a.security_advisory_cve_id as "CVE",
      a.security_advisory_severity as "Severity",
      a.dependency_package_name as "Package",
      a.dependency_scope as "Scope",
      a.created_at as "Alert Created",
      age(now()::date, a.created_at::date) as "Alert Age",
      a.html_url as "advisory_url",
      o.url
    from
      github_my_organization o
    join
      github_organization_dependabot_alert a
    on
      o.login = a.organization
    where
      a.state = 'open';
  EOQ
}