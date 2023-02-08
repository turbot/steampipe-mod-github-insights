dashboard "branch_detail" {

  title         = "GitHub Branch Detail"
  documentation = file("./dashboards/branch/docs/branch_detail.md")

  tags = merge(local.branch_common_tags, {
    type = "Detail"
  })

  input "repository_full_name" {
    title = "Select a repository:"
    query = query.repository_input
    width = 4
  }

  input "branch_name" {
    title = "Select a branch:"
    query = query.branch_input
    width = 4
    args = {
      repository_full_name = self.input.repository_full_name.value
    }
  }

  container {
    card {
      width = 2
      query = query.branch_protection_status
      args = {
        repository_full_name = self.input.repository_full_name.value
        branch_name          = self.input.branch_name.value
      }
    }
  }

  with "prs_for_base_ref_branch" {
    query = query.prs_for_base_ref_branch
    args = {
      repository_full_name = self.input.repository_full_name.value
      branch_name          = self.input.branch_name.value
    }
  }

  with "prs_for_head_branch" {
    query = query.prs_for_head_branch
    args = {
      repository_full_name = self.input.repository_full_name.value
      branch_name          = self.input.branch_name.value
    }
  }

  container {
    graph {
      title = "Relationships"
      type  = "graph"

      node {
        base = node.repository
        args = {
          repository_full_names = [self.input.repository_full_name.value]
        }
      }

      node {
        base = node.pull_request
        args = {
          repository_full_name = self.input.repository_full_name.value
          pull_request_ids     = with.prs_for_base_ref_branch.rows[*].pr_id
        }
      }

      node {
        base = node.pull_request
        args = {
          repository_full_name = self.input.repository_full_name.value
          pull_request_ids     = with.prs_for_head_branch.rows[*].pr_id
        }
      }

      node {
        base = node.branch
        args = {
          branch_names          = [self.input.branch_name.value]
          repository_full_names = [self.input.repository_full_name.value]
        }
      }

      // node {
      //   base = node.user
      //   args = {
      //     logins = with.collaborators.rows[*].login
      //   }
      // }

      edge {
        base = edge.repository_to_branch
        args = {
          branch_names          = [self.input.branch_name.value]
          repository_full_names = [self.input.repository_full_name.value]
        }
      }

      edge {
        base = edge.pull_request_to_branch
        args = {
          branch_names          = [self.input.branch_name.value]
          repository_full_names = [self.input.repository_full_name.value]
        }
      }

      edge {
        base = edge.branch_to_pull_request
        args = {
          branch_names          = [self.input.branch_name.value]
          repository_full_names = [self.input.repository_full_name.value]
        }
      }
    }
  }

  container {

    table {
      title = "Overview"
      type  = "line"
      width = 3
      query = query.branch_overview
      args = {
        repository_full_name = self.input.repository_full_name.value
        branch_name          = self.input.branch_name.value
      }
    }

    table {
      title = "Protections"
      width = 9
      query = query.branch_protections
      args = {
        repository_full_name = self.input.repository_full_name.value
        branch_name          = self.input.branch_name.value
      }
    }

  }

}

query "branch_input" {
  sql = <<-EOQ
    select
      name as label,
      name as value
    from
      github_branch
    where
      repository_full_name = $1
    order by
      name;
  EOQ

  param "repository_full_name" {}
}

query "branch_overview" {
  sql = <<-EOQ
    select
      repository_full_name as "Repository",
      name as "Branch"
    from
      github_branch
    where
      repository_full_name = $1 and
      name = $2;
  EOQ

  param "repository_full_name" {}
  param "branch_name" {}
}

query "branch_protection_status" {
  sql = <<-EOQ
    select
      'Protection' as "label",
      case
        when protected then 'Enabled'
        else 'Disabled'
      end as "value",
      case
        when protected then 'ok'
        else 'alert'
      end as "type"
    from
      github_branch
    where
      repository_full_name = $1 and
      name = $2;
  EOQ

  param "repository_full_name" {}
  param "branch_name" {}
}

query "branch_protections" {
  sql = <<-EOQ
    select
      case
        when allow_deletions_enabled then 'Enabled'
        else 'Disabled'
      end as "Allow Deletions",

      case
        when allow_force_pushes_enabled then 'Enabled'
        else 'Disabled'
      end as "Allow Force Pushes",

      case
        when enforce_admins_enabled then 'Enabled'
        else 'Disabled'
      end as "Enforce Admins",

      case
        when required_conversation_resolution_enabled then 'Enabled'
        else 'Disabled'
      end as "Required Conversation Resolution",

      case
        when required_linear_history_enabled then 'Enabled'
        else 'Disabled'
      end as "Required Linear History",

      case
        when signatures_protected_branch_enabled then 'Enabled'
        else 'Disabled'
      end as "Signatures Protected Branch"

    from
      github_branch_protection
    where
      repository_full_name = $1 and
      name = $2;
  EOQ

  param "repository_full_name" {}
  param "branch_name" {}
}

query "prs_for_base_ref_branch" {
  sql = <<-EOQ
    select
      issue_number as pr_id
    from
      github_pull_request
    where
      repository_full_name = $1
      and base_ref = $2
      and state = 'open'
  EOQ

  param "repository_full_name" {}
  param "branch_name" {}
}

query "prs_for_head_branch" {
  sql = <<-EOQ
    select
      issue_number as pr_id
    from
      github_pull_request
    where
      repository_full_name = $1
      and head_ref = $2
      and state = 'open'
  EOQ

  param "repository_full_name" {}
  param "branch_name" {}
}