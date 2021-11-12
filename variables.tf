variable "tfe_org" {
  type    = string
  default = "fancycorp"
}

# Create one by hand per instructions in https://www.terraform.io/docs/cloud/vcs/github.html
# Easier than trying to get TF to talk to GitHub etc.
# https://github.com/settings/applications/1722465
# https://app.terraform.io/app/fancycorp/settings/version-control
#
# OAuth Token ID from https://app.terraform.io/app/fancycorp/settings/version-control
variable "vcs_oauth_github" {
  type    = string
  default = "ot-8hSCfUe8VncQMmW6"
}
