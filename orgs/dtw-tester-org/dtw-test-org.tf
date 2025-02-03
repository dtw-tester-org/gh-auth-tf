provider "github" {}
data "github_user" "self" {
  username = ""
}

module "github_access" {
  source = "../../tf/modules/gh_access"

  data_dir    = "./data"
  github_user = coalesce(data.github_user.self.username, data.github_user.self.login)
}
