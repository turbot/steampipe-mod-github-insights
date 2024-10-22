dashboard "organization_member_privileges_report" {
  title = "GitHub Organization Member Privileges Report"
  documentation = file("./dashboards/organization/docs/organization_member_report_privileges.md")

  tags = merge(local.organization_common_tags, {
    type = "Report"
  })

  container {
    card {
      query = query.organization_count
      width = 3
    }
  }

  container {
    table {
      title = "Organization Member Privileges"
      query = query.organization_member_privileges_table

      column "url" {
        display = "none"
      }

      column "Organization" {
        href = "{{.'url'}}"
      }
    }
  }
}

query "organization_member_privileges_table" {
  sql = <<-EOQ
    select
      login as "Organization",
      default_repo_permission as "Base Permission",
      members_allowed_repository_creation_type as "Create Repo Type",
      members_can_create_repos as "Create Repository",
      members_can_create_public_repos as "Create Public Repository",
      members_can_create_private_repos as "Create Private Repository",
      members_can_fork_private_repos as "Fork Private Repository",
      members_can_create_pages as "Create Pages",
      url
    from
      github_my_organization;
  EOQ
}