dashboard "organization_detail" {

  title         = "GitHub Organization Detail"
  documentation = file("./dashboards/organization/docs/organization_detail.md")

  tags = merge(local.organization_common_tags, {
    type = "Detail"
  })

  input "organization_login" {
    title = "Select a organization:"
    query = query.organization_input
    width = 4
  }

  # Top cards
  container {

    card {
      query = query.organization_members_count
      width = 2
      args = {
        organization_login = self.input.organization_login.value
      }
    }

    card {
      query = query.organization_total_private_repos
      width = 2
      args = {
        organization_login = self.input.organization_login.value
      }
    }

    card {
      query = query.organization_public_repos
      width = 2
      args = {
        organization_login = self.input.organization_login.value
      }
    }

    # Assessment
    card {
      query = query.organization_two_factor_requirement
      width = 2
      args = {
        organization_login = self.input.organization_login.value
      }
    }

    card {
      query = query.organization_unused_seats
      width = 2
      args = {
        organization_login = self.input.organization_login.value
      }
    }
  }

  with "teams_for_organization" {
    query = query.teams_for_organization
    args  = [self.input.organization_login.value]
  }

  with "repositories_for_organization" {
    query = query.repositories_for_organization
    args  = [self.input.organization_login.value]
  }

  with "members_for_organization" {
    query = query.members_for_organization
    args  = [self.input.organization_login.value]
  }

  container {
    graph {
      title = "Relationships"
      type  = "graph"

      node {
        base = node.organization
        args = {
          organization_logins = [self.input.organization_login.value]
        }
      }

      node {
        base = node.repository
        args = {
          repository_full_names = with.repositories_for_organization.rows[*].full_name
        }
      }

      node {
        base = node.team
        args = {
          organization_logins = [self.input.organization_login.value]
        }
      }

      node {
        base = node.user
        args = {
          logins = with.members_for_organization.rows[*].member_login
        }
      }

      edge {
        base = edge.organization_to_repository
        args = {
          organization_logins = self.input.organization_login.value
          team_slugs          = with.teams_for_organization.rows[*].slug
        }
      }

      edge {
        base = edge.team_to_repository
        args = {
          organization_logins = self.input.organization_login.value
          team_slugs          = with.teams_for_organization.rows[*].slug
        }
      }

      edge {
        base = edge.organization_to_team
        args = {
          organization_logins = [self.input.organization_login.value]
        }
      }

      edge {
        base = edge.organization_to_user
        args = {
          organization_logins = self.input.organization_login.value
          team_slugs          = with.teams_for_organization.rows[*].slug
        }
      }

      edge {
        base = edge.team_to_user
        args = {
          organization_logins = self.input.organization_login.value
          team_slugs          = with.teams_for_organization.rows[*].slug
        }
      }
    }
  }

  container {

    table {
      title = "Overview"
      type  = "line"
      width = 3
      query = query.organization_overview
      args = {
        organization_login = self.input.organization_login.value
      }
      column "html_url" {
        display = "none"
      }
      column "organization_login" {
        href = "{{.'html_url'}}"
      }
    }

    table {
      title = "Social"
      type  = "line"
      width = 3
      query = query.organization_social
      args = {
        organization_login = self.input.organization_login.value
      }
    }

    table {
      title = "Permissions"
      type  = "line"
      width = 3
      query = query.organization_permissions
      args = {
        organization_login = self.input.organization_login.value
      }
    }
  }
}

# Card Queries

query "organization_members_count" {
  sql = <<-EOQ
    select jsonb_array_length(members) as "Members" from github_my_organization where login = $1;
  EOQ

  param "organization_login" {}
}

query "organization_total_private_repos" {
  sql = <<-EOQ
    select total_private_repos as "Private Repos" from github_my_organization where login = $1;
  EOQ

  param "organization_login" {}
}

query "organization_public_repos" {
  sql = <<-EOQ
    select public_repos as "Public Repos" from github_my_organization where login = $1;
  EOQ

  param "organization_login" {}
}

query "organization_two_factor_requirement" {
  sql = <<-EOQ
    select
      case
        when two_factor_requirement_enabled then 'Enabled'
        else 'Disabled'
      end as value,
      'Two-Factor Authentication (2FA)' as label,
      case
        when two_factor_requirement_enabled then 'ok'
        else 'alert'
      end as type
    from
      github_my_organization
    where
      login = $1;
  EOQ

  param "organization_login" {}
}

query "organization_unused_seats" {
  sql = <<-EOQ
    select
      'Billed Unused Seats' as label,
      case
        when (plan_seats - plan_filled_seats) >= 0 then (plan_seats - plan_filled_seats)
        else 0
      end as value,
      case
        when plan_filled_seats >= plan_seats then 'ok'
        else 'alert'
      end as type
    from
      github_my_organization
    where
      login = $1;
  EOQ

  param "organization_login" {}
}

query "organization_input" {
  sql = <<-EOQ
    select
      login as label,
      login as value
    from
      github_my_organization
    order by
      login;
  EOQ
}

query "repositories_for_organization" {
  sql = <<-EOQ
    select 
      full_name 
    from 
      github_my_repository 
    where 
      owner_login = $1;
  EOQ
}

query "teams_for_organization" {
  sql = <<-EOQ
    select 
      slug 
    from 
      github_my_team 
    where 
      organization_login = $1;
  EOQ
}

query "members_for_organization" {
  sql = <<-EOQ
    select
      om.login as member_login
    from
      github_my_organization as o
    join github_organization_member om
      on om.organization = o.login
    join jsonb_array_elements(o.members) as m
      on om.login = m.value ->> 'login'
    where
      o.login = $1
    order by
      om.role, upper(om.login)
  EOQ

  param "organization_login" {}
}

query "organization_overview" {
  sql = <<-EOQ
    select
      id as "ID",
      name as "Name",
      login as "Organization Login",
      company as "Company",
      description as "Description",
      created_at as "Created At",
      html_url,
      location as "Location",
      plan_name as "Plan Name",
      plan_seats as "Plan Seats",
      plan_filled_seats as "Plan Filled Seats",
      private_gists as "Private Gists",
      public_gists as "Public Gists"
    from
      github_my_organization
    where
      login = $1;
  EOQ

  param "organization_login" {}
}

query "organization_permissions" {
  sql = <<-EOQ
    select
      case
        when members_can_create_internal_repos then 'Enabled'
        else 'Disabled'
      end as "Members Can Create Internal Repos",
      case
        when members_can_create_pages then 'Enabled'
        else 'Disabled'
      end as "Members Can Create Pages",
      case
        when members_can_create_private_repos then 'Enabled'
        else 'Disabled'
      end as "Members Can Create Private Repos",
      case
        when members_can_create_public_repos then 'Enabled'
        else 'Disabled'
      end as "Members Can Create Public Repos",
      case
        when members_can_create_repos then 'Enabled'
        else 'Disabled'
      end as "Members Can Create Repos",
      case
        when members_can_fork_private_repos then 'Enabled'
        else 'Disabled'
      end as "Members Can Fork Private Repos",
      members_allowed_repository_creation_type as "Repository Types A Non-Admin Members Can Create",
      default_repo_permission as "Default Repo Permission"
    from
      github_my_organization
    where
      login = $1;
  EOQ

  param "organization_login" {}
}

query "organization_social" {
  sql = <<-EOQ
    select
      followers as "Followers",
      following as "Following",
      twitter_username as "Twitter Username",
      blog as "Blog",
      email as "Email"
    from
      github_my_organization
    where
      login = $1;
  EOQ

  param "organization_login" {}
}
