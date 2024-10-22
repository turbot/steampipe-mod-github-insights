category "repository" {
  title = "Repository"
  icon = "rebase_edit"
}

locals {
  repository_common_tags = {
    service = "GitHub/Repository"
  }
}

query "repository_count" {
  sql = <<-EOQ
    select
      count(*) as "Repositories"
    from
      github_my_repository;
  EOQ
}