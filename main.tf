terraform {
  required_providers {
    tfe = {
      version = "~> 0.26.0"
    }
  }
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "fancycorp"

    workspaces {
      name = "demo-tfcb-seed"
    }
  }
}

provider "tfe" {
}


resource "tfe_workspace" "webserver" {
  name         = "webserver-Test_London"
  description  = "Placeholder Webserver - Test London"
  organization = "fancycorp"
  tag_names    = ["webserver", "london"]
  auto_apply   = true


  # TODO: vcs_repo, this one
  # TODO: working_directory, webserver
}


# TODO: populate AWS creds, from this workspace's env vars
# https://registry.terraform.io/providers/EppO/environment/latest
# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable
