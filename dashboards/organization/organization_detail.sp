dashboard "github_organization_detail" {

  title = "GitHub Organization Detail"
  // documentation = file("./details/organization/docs/organization_detail.md")

  tags = merge(local.organization_common_tags, {
    type = "Detail"
  })

  input "organization_login" {
    title = "Select a organization:"
    query = query.github_organization_input
    width = 4
  }

  # Top cards
  container {

    card {
      query = query.github_organization_members_count
      width = 2
      args  = {
        login = self.input.organization_login.value
      }
    }
    card {
      query = query.github_organization_total_private_repos
      width = 2
      args  = {
        login = self.input.organization_login.value
      }
    }
    card {
      query = query.github_organization_public_repos
      width = 2
      args  = {
        login = self.input.organization_login.value
      }
    }
    card {
      query = query.github_organization_verified
      width = 2
      args  = {
        login = self.input.organization_login.value
      }
    }
    # Assessment
    card {
      query = query.github_organization_two_factor_requirement
      width = 2
      args  = {
        login = self.input.organization_login.value
      }
    }
    card {
      query = query.github_organization_unused_seats
      width = 2
      args  = {
        login = self.input.organization_login.value
      }
    }
  }

  container {

    table {
      title = "Overview"
      type  = "line"
      width = 3
      query = query.github_organization_overview
      args  = {
        login = self.input.organization_login.value
      }
      column "html_url" {
        display = "none"
      }
      column "Login" {
        href = "{{.'html_url'}}"
      }
    }

    table {
      title = "Social"
      type  = "line"
      width = 3
      query = query.github_organization_social
      args  = {
        login = self.input.organization_login.value
      }
    }

    table {
      title = "Permissions"
      type  = "line"
      width = 3
      query = query.github_organization_permissions
      args  = {
        login = self.input.organization_login.value
      }
    }

    table {
      title = "Members"
      width = 3
      query = query.github_organization_members
      args  = {
        login = self.input.organization_login.value
      }
      column "html_url" {
        display = "none"
      }
      column "Login" {
        href = "{{.'html_url'}}"
      }
    }
  }
}

# Card Queries

query "github_organization_members_count" {
  sql = <<-EOQ
    select jsonb_array_length(members) as "Members" from github_my_organization where login = $1;
  EOQ

  param "login" {}
}

query "github_organization_total_private_repos" {
  sql = <<-EOQ
    select total_private_repos as "Private Repos" from github_my_organization where login = $1;
  EOQ

  param "login" {}
}

query "github_organization_public_repos" {
  sql = <<-EOQ
    select public_repos as "Public Repos" from github_my_organization where login = $1;
  EOQ

  param "login" {}
}

query "github_organization_two_factor_requirement" {
  sql = <<-EOQ
    select
      case
        when two_factor_requirement_enabled then 'Enabled'
        else 'Disabled'
      end as value,
      '2FA Requirement' as label,
      case
        when two_factor_requirement_enabled then 'ok'
        else 'alert'
      end as type
    from
      github_my_organization
    where
      login = $1;
  EOQ

  param "login" {}
}

query "github_organization_verified" {
  sql = <<-EOQ
    select
      case
        when is_verified then 'Enabled'
        else 'Disabled'
      end as value,
      'Domain verified' as label
    from
      github_my_organization
    where
      login = $1;
  EOQ

  param "login" {}
}

query "github_organization_unused_seats" {
  sql = <<-EOQ
    select
      'Unused Seats' as label,
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

  param "login" {}
}

query "github_organization_input" {
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

query "github_organization_overview" {
  sql = <<-EOQ
    select
      name as "Name",
      login as "Login",
      company as "Company",
      description as "Description",
      created_at as "Created At",
      has_organization_projects as "Has Organization Projects",
      has_repository_projects as "Has Repository Projects",
      html_url,
      id as "ID",
      location as "Location",
      node_id as "Node ID",
      plan_name as "Plan Name",
      plan_seats as "Plan Seats",
      plan_filled_seats as "Plan Filled Seats",
      plan_private_repos as "Plan Private Repos",
      private_gists as "Private Gists",
      public_gists as "Public Gists"
    from
      github_my_organization
    where
      login = $1;
  EOQ

  param "login" {}
}

query "github_organization_permissions" {
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

  param "login" {}
}

query "github_organization_social" {
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

  param "login" {}
}

query "github_organization_members" {
  sql = <<-EOQ
    select
      om.login as "Login",
      initcap(om.role) as "Role",
      m.value ->> 'html_url' as "html_url"
    from
      github_my_organization as o
    join
      github_organization_member om
    on
      om.organization = o.login
    join
      jsonb_array_elements(o.members) as m
    on
      om.login = m.value ->> 'login'
    where
      o.login = $1
    order by
      om.role, upper(om.login);
  EOQ

  param "login" {}
}
