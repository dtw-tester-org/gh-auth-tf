output "teams" {
  value = {
    members : github_membership.all,
    membership : local.team_members,
    teams : github_team.all,
    user : {
      username : data.github_user.self.username,
      login : data.github_user.self.login
    }
  }
}
