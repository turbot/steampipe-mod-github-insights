dashboard "team_detail" {

  title         = "GitHub Team Detail"
  documentation = file("./dashboards/team/docs/team_detail.md")

  tags = merge(local.team_common_tags, {
    type = "Detail"
  })

  input "organization_team_slug_input" {
    placeholder = "Select a team"
    query       = query.team_input
    width       = 4
  }

  # Top cards
  container {

    card {
      query = query.team_members_count
      width = 2
      args = {
        organization_team_slug = self.input.organization_team_slug_input.value
      }
    }

    card {
      query = query.team_repos_count
      width = 2
      args = {
        organization_team_slug = self.input.organization_team_slug_input.value
      }
    }

    card {
      query = query.team_privacy
      width = 2
      args = {
        organization_team_slug = self.input.organization_team_slug_input.value
      }
    }

    card {
      query = query.team_members_inactive_count
      width = 2
      args = {
        organization_team_slug = self.input.organization_team_slug_input.value
      }
    }

  }

  with "current_team" {
    query = query.current_team
    args  = [self.input.organization_team_slug_input.value]
  }

  with "parent_teams_for_team" {
    query = query.parent_teams_for_team
    args  = [self.input.organization_team_slug_input.value]
  }

  with "child_teams_for_team" {
    query = query.child_teams_for_team
    args  = [self.input.organization_team_slug_input.value]
  }

  with "parent_organizations_for_team" {
    query = query.parent_organizations_for_team
    args  = [self.input.organization_team_slug_input.value]
  }

  with "organizations_for_team" {
    query = query.organizations_for_team
    args  = [self.input.organization_team_slug_input.value]
  }

  with "repositories_for_team" {
    query = query.repositories_for_team
    args  = [self.input.organization_team_slug_input.value]
  }

  with "members_for_team" {
    query = query.members_for_team
    args  = [self.input.organization_team_slug_input.value]
  }

  container {
    graph {
      title = "Relationships"
      type  = "graph"

      node {
        base = node.organization
        args = {
          organization_logins = with.parent_organizations_for_team.rows[*].organization_login
        }
      }

      node {
        base = node.repository
        args = {
          repository_full_names = with.repositories_for_team.rows[*].repository_full_name
        }
      }

      node {
        base = node.team
        args = {
          organization_logins = with.organizations_for_team.rows[*].organization_login
          team_slugs          = with.current_team.rows[*].slug
        }
      }

      node {
        base = node.team
        args = {
          organization_logins = with.organizations_for_team.rows[*].organization_login
          team_slugs          = with.parent_teams_for_team.rows[*].slug
        }
      }

      node {
        base = node.team
        args = {
          organization_logins = with.organizations_for_team.rows[*].organization_login
          team_slugs          = with.child_teams_for_team.rows[*].slug
        }
      }

      node {
        base = node.user
        args = {
          logins = with.members_for_team.rows[*].login
        }
      }

      edge {
        base = edge.team_to_repository
        args = {
          organization_logins = with.organizations_for_team.rows[0].organization_login
          team_slugs          = with.current_team.rows[*].slug
        }
      }

      edge {
        base = edge.organization_to_team
        args = {
          organization_logins = with.parent_organizations_for_team.rows[*].organization_login
        }
      }

      edge {
        base = edge.team_to_team
        args = {
          organization_logins = with.organizations_for_team.rows[*].organization_login
        }
      }

      edge {
        base = edge.team_to_user
        args = {
          organization_logins = with.organizations_for_team.rows[0].organization_login
          team_slugs          = with.current_team.rows[*].slug
        }
      }
    }
  }

  container {

    container {

      table {
        title = "Overview"
        type  = "line"
        width = 3
        query = query.team_overview
        args = {
          organization_team_slug = self.input.organization_team_slug_input.value
        }
      }

      table {
        title = "Member Details"
        width = 9
        query = query.team_member_details
        args = {
          organization_team_slug = self.input.organization_team_slug_input.value
        }
        column "html_url" {
          display = "none"
        }
        column "ID" {
          href = "{{.'html_url'}}"
        }
      }
    }

    container {
      title = "Analysis"

      chart {
        title = "Repositories by Language"
        type  = "column"
        width = 6
        query = query.team_repository_by_language
        args = {
          organization_team_slug = self.input.organization_team_slug_input.value
        }
      }

      chart {
        title = "Repositories by Stargazers - Top 10"
        type  = "column"
        width = 4
        query = query.team_repository_by_stargazers_top_10
        args = {
          organization_team_slug = self.input.organization_team_slug_input.value
        }
      }
    }
  }

  container {

    table {
      title = "Repository Details"
      query = query.team_repository_details
      args = {
        organization_team_slug = self.input.organization_team_slug_input.value
      }

      column "html_url" {
        display = "none"
      }

      column "ID" {
        href = "{{.'html_url'}}"
      }
    }
  }
}

query "team_input" {
  sql = <<-EOQ
    select
      name as label,
      json_build_object(
        'slug', slug,
        'organization_login', organization
      ) as tags,
      organization_login || '/' || slug as value
    from
      github_team
    order by
      organization,
      name;
  EOQ
}

# Card Queries

query "team_members_count" {
  sql = <<-EOQ
    select
      members_count as "Members" 
    from 
      github_team 
    where 
      organization_login = split_part($1, '/', 1)
      and slug = split_part($1, '/', 2);
  EOQ

  param "organization_team_slug" {}
}

query "team_repos_count" {
  sql = <<-EOQ
    select
      repos_count as "Repositories" 
    from 
      github_team 
    where 
      organization_login = split_part($1, '/', 1)
      and slug = split_part($1, '/', 2);
  EOQ

  param "organization_team_slug" {}
}

query "team_privacy" {
  sql = <<-EOQ
    select
      initcap(privacy) as "Privacy" 
    from 
      github_team 
    where 
      organization_login = split_part($1, '/', 1)
      and slug = split_part($1, '/', 2);
  EOQ

  param "organization_team_slug" {}
}

query "team_members_inactive_count" {
  sql = <<-EOQ
    select
      'Inactive Members' as label,
      count(*) as value,
      case
        when count(*) > 0 then 'alert'
        else 'ok'
      end as type
    from
      github_team_member
    where
      organization = split_part($1, '/', 1)
      and slug = split_part($1, '/', 2)
      and state = 'inactive';
  EOQ

  param "organization_team_slug" {}
}

query "team_overview" {
  sql = <<-EOQ
    select
      id as "ID",
      name as "Name",
      slug as "Team Slug",
      description as "Description",
      organization_login as "Organization",
      case when
        parent is null then 'None'
        else parent ->> 'slug' 
      end as "Parent Team",
      permission as "Permission"
    from
      github_team
    where
      organization_login = split_part($1, '/', 1)
      and slug = split_part($1, '/', 2);
  EOQ

  param "organization_team_slug" {}
}

# With Queries

query "parent_teams_for_team" {
  sql = <<-EOQ
    select
      parent ->> 'slug' as slug
    from
      github_team
    where
      organization = split_part($1, '/', 1)
      and slug = split_part($1, '/', 2)
      and parent is not null;
  EOQ

  param "organization_team_slug" {}
}

query "parent_organizations_for_team" {
  sql = <<-EOQ
    select
      organization_login
    from
      github_team
    where
      organization = split_part($1, '/', 1)
      and slug = split_part($1, '/', 2)
      and parent is null;
  EOQ

  param "organization_team_slug" {}
}

query "child_teams_for_team" {
  sql = <<-EOQ
    select
      slug
    from
      github_team
    where
      organization = split_part($1, '/', 1)
      and parent ->> 'slug' = split_part($1, '/', 2);
  EOQ

  param "organization_team_slug" {}
}

query "members_for_team" {
  sql = <<-EOQ
    select
      login
    from
      github_team_member
    where
      organization = split_part($1, '/', 1)
      and slug = split_part($1, '/', 2);
  EOQ

  param "organization_team_slug" {}
}

query "repositories_for_team" {
  sql = <<-EOQ
    select
      full_name as repository_full_name
    from
      github_team_repository
    where
      organization = split_part($1, '/', 1)
      and slug = split_part($1, '/', 2);
  EOQ

  param "organization_team_slug" {}
}

query "current_team" {
  sql = <<-EOQ
    select
      slug
    from
      github_team
    where
      organization_login = split_part($1, '/', 1)
      and slug = split_part($1, '/', 2);
  EOQ

  param "organization_team_slug" {}
}

query "organizations_for_team" {
  sql = <<-EOQ
    select split_part($1, '/', 1) as organization_login;
  EOQ

  param "organization_team_slug" {}
}

# Analysis Queries

query "team_member_details" {
  sql = <<-EOQ
    select
      id as "ID",
      login as "Member Login",
      initcap(state) as "State",
      initcap(role) as "Permission",
      type as "Member Type",
      html_url
    from
      github_team_member
    where
      organization = split_part($1, '/', 1)
      and slug = split_part($1, '/', 2);
  EOQ

  param "organization_team_slug" {}
}

query "team_repository_details" {
  sql = <<-EOQ
    select
      id as "ID",
      full_name as "Repository Full Name",
      language as "Language",
      initcap(visibility) as "Visibility",
      created_at as "Creation Date",
      now()::date - updated_at::date as "Days Since Last Update",
      open_issues_count as "Open Issues",
      stargazers_count as "Stargazers",
      license_name as "License Name",
      html_url
    from
      github_team_repository
    where
      organization = split_part($1, '/', 1)
      and slug = split_part($1, '/', 2);
  EOQ

  param "organization_team_slug" {}
}

query "team_repository_by_language" {
  sql = <<-EOQ
    with repo_languages as(
      select
        id,
        case
          when language is null then 'Unspecified'
          else language
        end as language
      from
        github_team_repository
      where
        organization = split_part($1, '/', 1)
        and slug = split_part($1, '/', 2)
    )select
      language,
      count(*)
    from
      repo_languages
    group by
      language
    order by
      count desc;
  EOQ

  param "organization_team_slug" {}
}

query "team_repository_by_stargazers_top_10" {
  sql = <<-EOQ
    select
      name,
      stargazers_count
    from
      github_team_repository
    where
      organization = split_part($1, '/', 1)
      and slug = split_part($1, '/', 2)
    order by
      stargazers_count desc
    limit 10;
  EOQ

  param "organization_team_slug" {}
}
