dashboard "repository_stargazer_report" {
  title = "GitHub Repository Stargazers Report"
  documentation = file("./dashboards/repository/docs/repository_report_stargazer.md")

  tags = merge(local.repository_common_tags, {
    type = "Report"
  })

  container {
    card {
      query = query.repository_count
      width = 2
    }

    card {
      query = query.repository_unstarred_count
      width = 2
    }

    card {
      query = query.repository_1_100_stars_count
      width = 2
    }

    card {
      query = query.repository_101_500_stars_count
      width = 2
    }

    card {
      query = query.repository_501_1000_stars_count
      width = 2
    }

    card {
      query = query.repository_over_1000_stars_count
      width = 2
    }
  }

  container {
    table {
      title = "Repository Stargazers"
      query = query.repository_stargazer_table

      column "url" {
        display = "none"
      }

      column "Repository" {
        href = "{{.'url'}}"
      }
    }
  }
}

query "repository_unstarred_count" {
  sql = <<-EOQ
    select
      'Unstarred' as label,
      count(*) as value
    from
      github_my_repository
    where
      stargazer_count = 0;
  EOQ
}

query "repository_1_100_stars_count" {
  sql = <<-EOQ
    select
      '1-100 Stars' as label,
      count(*) as value
    from
      github_my_repository
    where
      stargazer_count between 1 and 100;
  EOQ
}

query "repository_101_500_stars_count" {
  sql = <<-EOQ
    select
      '101-500 Stars' as label,
      count(*) as value
    from
      github_my_repository
    where
      stargazer_count between 101 and 500;
  EOQ
}

query "repository_501_1000_stars_count" {
  sql = <<-EOQ
    select
      '501-1000 Stars' as label,
      count(*) as value
    from
      github_my_repository
    where
      stargazer_count between 501 and 1000;
  EOQ
}

query "repository_over_1000_stars_count" {
  sql = <<-EOQ
    select
      'Over 1000 Stars' as label,
      count(*) as value
    from
      github_my_repository
    where
      stargazer_count > 1000;
  EOQ
}

query "repository_stargazer_table" {
  sql = <<-EOQ
    select
      name_with_owner as "Repository",
      stargazer_count as "Stargazers",
      url
    from
      github_my_repository
    order by
      stargazer_count DESC, name_with_owner;
  EOQ
}