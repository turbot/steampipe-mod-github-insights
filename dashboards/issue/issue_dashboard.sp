dashboard "issue_dashboard" {

  title         = "GitHub Issue Dashboard"
  documentation = file("./dashboards/issue/docs/issue_dashboard.md")

  tags = merge(local.issue_common_tags, {
    type = "Dashboard"
  })

  input "repository_full_name" {
    placeholder = "Select a repository"
    query       = query.repository_input
    width       = 4
  }

  # Top cards
  container {

    card {
      query = query.issue_count
      width = 3
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }
    card {
      query = query.issue_open_count
      width = 3
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }

    # Assessment
    card {
      query = query.issue_open_longer_than_30_days_count
      width = 3
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }
    card {
      query = query.issue_open_unassigned_count
      width = 3
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }
  }

  container {

    title = "Assessments"

    chart {
      title = "Open Issues"
      query = query.issues_by_state
      type  = "donut"
      width = 3

      args = {
        repository_full_name = self.input.repository_full_name.value
      }

      series "count" {
        point "closed" {
          color = "ok"
        }
        point "open" {
          color = "alert"
        }
      }
    }

  }

  container {
    title = "Analysis"

    chart {
      title = "Issues by Tag"
      type  = "column"
      width = 4
      query = query.issues_by_tag
      args = {
        repository_full_name = self.input.repository_full_name.value
      }

      series closed {
        title = "Closed Issues"
        color = "#0C457D"
      }
      series open {
        title = "Open Issues"
        color = "#E8702B"
      }
    }

    chart {
      title    = "Issues by Age"
      type     = "area"
      grouping = "stack"
      width    = 4
      query    = query.issue_by_age
      args = {
        repository_full_name = self.input.repository_full_name.value
      }

      series closed {
        title = "Closed Issues"
        color = "#0C457D"
      }
      series open {
        title = "Open Issues"
        color = "#E8702B"
      }

    }

    chart {
      title = "Issues by Lifetime (Open - Close)"
      type  = "column"
      width = 4
      query = query.issue_by_lifetime
      args = {
        repository_full_name = self.input.repository_full_name.value
      }
    }
  }

  table {
    title = "Issues - Last 7 Days"
    width = 12
    query = query.repository_recent_issues
    args = {
      repository_full_name = self.input.repository_full_name.value
    }
    column "html_url" {
      display = "none"
    }
    column "Issue" {
      href = "{{.'html_url'}}"
    }
  }
}

# Card Queries

query "issue_count" {
  sql = <<-EOQ
    select count(*) as "Issues" from github_issue where repository_full_name = $1;
  EOQ

  param "repository_full_name" {}
}
query "issue_open_count" {
  sql = <<-EOQ
    select count(*) as "Open Issues" from github_issue where repository_full_name = $1 and state = 'open';
  EOQ

  param "repository_full_name" {}
}

query "issue_open_longer_than_30_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Open > 30 days' as label,
      case
        when count(*) > 0 then 'alert'
        else 'ok'
      end as type
    from
      github_issue
    where
      repository_full_name = $1 and
      state = 'open' and
      created_at <= (current_date - interval '30' day);
  EOQ

  param "repository_full_name" {}
}

query "issue_open_unassigned_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Open Unassigned' as label,
      case
        when count(*) > 0 then 'alert'
        else 'ok'
      end as type
    from
      github_issue
    where
      repository_full_name = $1
      and jsonb_array_length(assignee_logins) = 0
      and state = 'open';
  EOQ

  param "repository_full_name" {}
}

# Analysis Queries

query "issues_by_state" {
  sql = <<-EOQ
    select
      state as "State",
      count(i.*)
    from
      github_issue i
    where
      repository_full_name = $1
    group by 
      state
    order by 
      count;
  EOQ

  param "repository_full_name" {}
}

query "issues_by_tag" {
  sql = <<-EOQ
    select
      t as "Tag",
      state,
      count(i.state) as total
    from
      github_issue i,
      jsonb_object_keys(tags) t
    where
      repository_full_name = $1
    group by 
      t, state
    order by 
      total desc;
  EOQ

  param "repository_full_name" {}
}

query "issue_by_age" {
  sql = <<-EOQ
    select
      to_char(created_at,
          'YYYY-MM') as creation_month,
      state,
      count(*) as total
    from
      github_issue
    where
      repository_full_name = $1
    group by
      state,
      creation_month;
  EOQ

  param "repository_full_name" {}
}

query "issue_by_lifetime" {
  sql = <<-EOQ
    with issue_lifetime as (
      select
        id,
        title,
        closed_at::date - created_at::date lifetime 
      from 
        github_issue
      where
        repository_full_name = $1
        and state != 'open'
      order by 
        lifetime
    ), issue_lifetime_group as (select
      title,
      lifetime,
      case
        when lifetime <= 1 then 1
        when lifetime > 1 and lifetime <= 3 then 3
        when lifetime > 3 and lifetime <= 7 then 7
        when lifetime > 7 and lifetime <= 15 then 15
        when lifetime > 15 and lifetime <= 30 then 30
        when lifetime > 30 and lifetime <= 90 then 90
        when lifetime > 90 and lifetime <= 365 then 365
        when lifetime > 365 then 366
      end as day_lifetime
    from
      issue_lifetime
    ) select
      case when day_lifetime = 366 then 'more' else day_lifetime || 'd' end as lifetime,
      count(*) as total
    from
      issue_lifetime_group
    group by
      day_lifetime
    order by
      day_lifetime
  EOQ

  param "repository_full_name" {}
}
