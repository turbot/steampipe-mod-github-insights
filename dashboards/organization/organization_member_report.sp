dashboard "organization_member_report" {

  title         = "GitHub Organization Member Report"
  documentation = file("./dashboards/organization/docs/organization_member_report.md")

  tags = merge(local.organization_common_tags, {
    type = "Report"
  })

  input "organization_member_report_login" {
    // title = "Select an organization:"
    placeholder = "Select an organization"
    query       = query.organization_input
    width       = 4
  }

  container {
    table {
      title = "Organization Members"
      query = query.organization_member_report
      args = {
        organization_member_report_login = self.input.organization_member_report_login.value
      }
      column "Member Login" {
        href = "{{.'html_url'}}"
      }
    }
  }
}

query "organization_member_report" {
  sql = <<-EOQ
    with members as (
      select
        login,
        role
      from
        github_organization_member
      where
        organization = $1
    )
    select
      u.login as "Member Login",
      name as "Name",
      initcap(role) as "Role",
      company as "Company",
      email as "Email",
      case when two_factor_authentication then 'Enabled' else 'Disabled' end as "Two Factor Authentication",
      location as "Location",
      blog as "Blog URL"
    from
      members as m
      left join github_user as u on u.login = m.login
    order by
      role, upper(u.login);
  EOQ

  param "organization_member_report_login" {}
}
