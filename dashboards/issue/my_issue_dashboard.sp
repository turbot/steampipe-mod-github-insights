dashboard "my_issue_dashboard" {

  title         = "GitHub My Assigned Issues Dashboard"
  documentation = file("./dashboards/issue/docs/my_issue_dashboard.md")

  tags = merge(local.issue_common_tags, {
    type = "Dashboard"
  })

  # Top cards
  container {

    card {
      query = query.my_issue_count
      width = 3
    }
    card {
      query = query.my_issue_open_count
      width = 3
    }

    # Assessment
    card {
      query = query.my_issue_open_longer_than_30_days_count
      width = 3
    }
  }

  container {

    title = "Assessments"

    chart {
      title = "Open Issues"
      query = query.my_issues_by_state
      type  = "donut"
      width = 3

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
      title    = "Issues By Age"
      type     = "area"
      grouping = "stack"
      width    = 4
      query    = query.my_issue_by_age

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
      title = "Issues by Tag"
      type  = "column"
      width = 4
      query = query.my_issues_by_tag

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
      title = "Issues by Repository"
      type  = "column"
      width = 4
      query = query.my_issue_by_repository

      series closed {
        title = "Closed Issues"
        color = "#0C457D"
      }
      series open {
        title = "Open Issues"
        color = "#E8702B"
      }
    }
  }

  table {
    title = "Open Issues"
    width = 12
    query = query.repository_my_issues

    column "html_url" {
      display = "none"
    }
    column "Issue" {
      href = "{{.'html_url'}}"
    }
  }
}

# Card Queries

query "my_issue_count" {
  sql = <<-EOQ
    select count(*) as "Issues" from github_my_issue;
  EOQ
}
query "my_issue_open_count" {
  sql = <<-EOQ
    select count(*) as "Open Issues" from github_my_issue where state = 'open';
  EOQ
}

query "my_issue_open_longer_than_30_days_count" {
  sql = <<-EOQ
    select
      count(*) as value,
      'Open > 30 days' as label,
      case
        when count(*) > 0 then 'alert'
        else 'ok'
      end as type
    from
      github_my_issue
    where
      state = 'open' and
      created_at <= (current_date - interval '30' day);
  EOQ
}

# Analysis Queries

query "my_issues_by_state" {
  sql = <<-EOQ
    select
      state as "State",
      count(i.*)
    from
      github_my_issue i
    group by 
      state
    order by 
      count;
  EOQ
}

query "my_issues_by_tag" {
  sql = <<-EOQ
    select
      t as "Tag",
      state,
      count(i.state) as total
    from
      github_my_issue i,
      jsonb_object_keys(tags) t
    group by 
      t, state
    order by 
      total desc;
  EOQ
}

query "my_issue_by_repository" {
  sql = <<-EOQ
    select
      repository_full_name,
      state,
      count(repository_full_name) as total
    from
      github_my_issue
    group by
      repository_full_name, state
    order by
      total desc;
  EOQ
}

query "my_issue_by_age" {
  sql = <<-EOQ
    select
      to_char(created_at,
          'YYYY-MM') as creation_month,
      state,
      count(*) as total
    from
      github_my_issue
    group by
      state,
      creation_month;
  EOQ
}

query "repository_my_issues" {
  sql = <<-EOQ
    select
      issue_number as "Issue",
      title as "Title",
      now()::date - created_at::date as "Age in Days",
      now()::date - updated_at::date as "Days Since Last Update",
      repository_full_name as "Repository",
      author_login as "Author",
      html_url
    from
      github_my_issue
    where
      state = 'open'
    order by 
      created_at;
  EOQ
}
