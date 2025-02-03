
data "github_user" "self" {
  username = var.github_user
}

variable "data_dir" {
  description = "The directory for your data files"
  type        = string
}

variable "github_user" {
  type = string
}
