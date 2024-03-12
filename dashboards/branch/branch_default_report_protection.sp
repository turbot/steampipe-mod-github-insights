dashboard "default_branch_protection_report" {
  title         = "GitHub Default Branch Protection Report"
  documentation = file("./dashboards/branch/docs/branch_default_report_protection.md")

  tags = merge(local.branch_common_tags, {
    type     = "Report"
    category = "Security"
  })

  container {
    card {
      query = query.repo_count
      width = 3
    }

    card {
      query = query.default_branch_protection_enabled_count
      width = 3
    }

    card {
      query = query.default_branch_protection_disabled_unverifiable_count
      width = 3
    }
  }

  container {
    table {
      title = "Default Branch Protection Rules"
      query = query.default_branch_protection_table

      column "url" {
        display = "none"
      }

      column "Repository" {
        href = "{{.'url'}}"
      }
    }
  }
}

query "repo_count" {
  sql = <<-EOQ
    with my_repos as (
      select
        name_with_owner,
        default_branch_ref,
        url
      from
        github_my_repository
    )
    select
      'Protected' as label,
      count(*) as value
    from
      my_repos
    where
      default_branch_ref -> 'branch_protection_rule' IS NOT NULL;
  EOQ
}

query "default_branch_protection_enabled_count" {
  sql = <<-EOQ
    with my_repos AS (
      select
        name_with_owner,
        default_branch_ref,
        url
      from
        github_my_repository
    )
    select
      'Protected' as label,
      count(*) as value
    from
      my_repos
    where
      (default_branch_ref -> 'branch_protection_rule') is not null;
  EOQ
}

query "default_branch_protection_disabled_unverifiable_count" {
  sql = <<-EOQ
    with my_repos AS (
      select
        name_with_owner,
        default_branch_ref,
        url
      from
        github_my_repository
    )
    select
      'Unknown' as label,
      count(*) as value,
      case
        when count(*) > 0 then 'alert'
        else 'ok'
      end as type
    from
      my_repos
    where
      (default_branch_ref -> 'branch_protection_rule') is null;
  EOQ
}

query "default_branch_protection_table" {
  sql = <<-EOQ
    with my_repos AS (
      select
        name_with_owner,
        default_branch_ref,
        url
      from
        github_my_repository
    )
    select
      name_with_owner as "Repository",
      (default_branch_ref ->> 'name') as "Default Branch",
      case
        when (default_branch_ref -> 'branch_protection_rule') is null then 'Unknown - manual check required'
        else 'Protected'
      end as "Protection Status",
      (default_branch_ref -> 'branch_protection_rule' ->> 'restricts_pushes')::bool as "Restricts Pushes",
      (default_branch_ref -> 'branch_protection_rule' ->> 'allows_force_pushes')::bool as "Allows Force Pushes",
      (default_branch_ref -> 'branch_protection_rule' ->> 'allows_deletions')::bool as "Allows Deletions",
      (default_branch_ref -> 'branch_protection_rule' ->> 'requires_approving_reviews')::bool as "Requires Approvals",
      (default_branch_ref -> 'branch_protection_rule' ->> 'requires_conversation_resolution')::bool as "Requires Conversation Resolution",
      (default_branch_ref -> 'branch_protection_rule' ->> 'requires_commit_signatures')::bool as "Requires Signed Commits",
      (default_branch_ref -> 'branch_protection_rule' ->> 'requires_linear_history')::bool as "Requires Linear History",
      (default_branch_ref -> 'branch_protection_rule' ->> 'is_admin_enforced')::bool as "Applies to Admins",
      url
    from
      my_repos
    order by
      name_with_owner;
  EOQ
}
