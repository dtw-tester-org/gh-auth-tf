locals {

  # Parse repo team membership files
  repo_teams_path = "../data/repos"
  repo_teams_files = {
    for file in fileset(local.repo_teams_path, "*.csv") :
    trimsuffix(file, ".csv") => csvdecode(file("${local.repo_teams_path}/${file}"))
  }
}


# Reference existing repositories instead of creating new ones
data "github_repository" "repos" {
  for_each = local.repo_teams_files
  name     = each.key
}

# Assign teams to existing repositories
resource "github_team_repository" "teams" {
  for_each = merge([
    for repo_name, teams in local.repo_teams_files : {
      for team in teams :
      "${repo_name}-${team.team_name}" => {
        team_id    = github_team.all[team.team_name].id
        repository = data.github_repository.repos[repo_name].id
        permission = team.permission
      } if lookup(github_team.all, team.team_name, false) != false
    }
  ]...)

  team_id    = each.value.team_id
  repository = each.value.repository
  permission = each.value.permission
}
