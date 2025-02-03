resource "github_team" "all" {
  for_each = {
    for team in csvdecode(file("${var.data_dir}/teams.csv")) :
    team.name => team
  }

  name                      = each.value.name
  description               = each.value.description
  privacy                   = each.value.privacy
  create_default_maintainer = false
  parent_team_id            = each.value.parent_team_slug

  lifecycle {
    # prevent_destroy = true
  }
}

resource "github_team_membership" "members" {
  for_each = { for tm in local.team_members : tm.name => tm }

  team_id  = each.value.team_id
  username = each.value.username
  role     = each.value.role
}

locals {

  team_members_path = "${var.data_dir}/membership/"
  team_members_files = {
    for file in fileset(local.team_members_path, "*.csv") :
    trimsuffix(file, ".csv") => csvdecode(file("${local.team_members_path}/${file}"))
  }
  # Create temp object that has team ID and CSV contents
  team_members_temp = flatten([
    for team, members in local.team_members_files : [
      for tn, t in github_team.all : {
        name    = t.name
        id      = t.id
        slug    = t.slug
        members = members
      } if t.slug == team
    ]
  ])

  # Create object for each team-user relationship
  team_members = flatten([
    for team in local.team_members_temp : [
      for member in team.members : {
        name     = "${team.slug}-${member.username}"
        team_id  = team.id
        username = member.username
        role     = member.role
      }
    ]
  ])
}
