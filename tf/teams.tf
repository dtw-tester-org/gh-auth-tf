# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "github_team" "all" {
  for_each = {
    for team in csvdecode(file("../data/teams.csv")) :
    team.name => team
  }

  name                      = each.value.name
  description               = each.value.description
  privacy                   = each.value.privacy
  create_default_maintainer = true
}

resource "github_team_membership" "members" {
  for_each = { for tm in local.team_members : tm.name => tm }

  team_id  = each.value.team_id
  username = each.value.username
  role     = each.value.role
}

locals {

  team_members_path = "../data/membership/"
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

  # Parse repo team membership files
  repo_teams_path = "../data/teams"
  repo_teams_files = {
    for file in fileset(local.repo_teams_path, "*.csv") :
    trimsuffix(file, ".csv") => csvdecode(file("${local.repo_teams_path}/${file}"))
  }
}
