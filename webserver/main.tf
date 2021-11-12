terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "fancycorp"

    workspaces {
      prefix = "webserver-"
    }
  }
}

# Random pet for now.
# Real example will spin up a webserver using the
# https://github.com/hashi-strawb/terraform-aws-webserver module
resource "random_pet" "server" {
}
