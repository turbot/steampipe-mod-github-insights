dashboard "organization_2fa_report" {
  title = "GitHub Organization 2FA Report"
  documentation = file("./dashboards/organization/docs/organization_2fa_report.md")
  
  tags = merge(local.organization_common_tags, {
    type = "Report"
  })

  container {
    card {
      query = query.organization_count
      width = 2
    }
    
    card {
      query = query.organization_2fa_enabled_count
      width = 2
    }

    card {
      query = query.organization_2fa_disabled_count
      width = 2
    }

    card {
      query = query.organization_2fa_unknown_count
      width = 2
      type  = "info"
    }
  }

  container {
    table {
      title = "Organization 2fa Settings"
      query = query.organization_2fa_table

      column "url" {
        display = "none"
      }

      column "Organization" {
        href = "{{.'url'}}"
      }
    }
  }
}

query "organization_2fa_enabled_count" {
  sql = <<-EOQ
    select
      'Enabled' as label,
      count(*) as value
    from
      github_my_organization
    where
      two_factor_requirement_enabled = true;
  EOQ
}

query "organization_2fa_disabled_count" {
  sql = <<-EOQ
    select
      'Disabled' as label,
      count(*) as value,
      case
        when count(*) > 0 then 'alert'
        else 'ok'
      end as type
    from
      github_my_organization
    where
      two_factor_requirement_enabled = false;
  EOQ
}

query "organization_2fa_unknown_count" {
  sql = <<-EOQ
    select
      'Unknown' as label,
      count(*) as value
    from
      github_my_organization
    where
      two_factor_requirement_enabled is null;
  EOQ
}

query "organization_2fa_table" {
  sql = <<-EOQ
    select
      login as "Organization",
      two_factor_requirement_enabled as "2fa Required",
      url
    from
      github_my_organization;
  EOQ
}