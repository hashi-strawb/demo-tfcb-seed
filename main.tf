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

/*
Check our webserver/ dir for YAML files, which will be converted to workspace

Expected Format:

$ cat webserver/London\ Test.yml
  type:         placeholder-webserver
  name:         London Test
  region:       London
  image_height: 400
  image_width:  560
  image_type:   Cat

*/

locals {
  webserver_workspace_files = fileset(path.module, "webserver/*.yml")
}



resource "tfe_workspace" "webserver" {
  for_each = local.webserver_workspace_files

  # In reality, you would want some kind of validation here
  # e.g. to check values exist, set default values if they don't,
  # check that values are from a specific list, etc.
  #
  # See https://lmhd.me/tech/2021/05/26/dynamic-terraform/ for an example

  # Replace spaces with underscores in workspace name
  name = "webserver-${replace(yamldecode(file(each.key))["name"], " ", "_")}"

  description  = "Placeholder Webserver - ${yamldecode(file(each.key))["name"]}"
  organization = "fancycorp"
  tag_names = [
    yamldecode(file(each.key))["type"],
    yamldecode(file(each.key))["region"],
    yamldecode(file(each.key))["image_type"],
  ]
  auto_apply = true


  # TODO: vcs_repo, this one
  # TODO: working_directory, webserver
}
# TODO: update the workspace with a PATCH, to set source-url and source-name:
# https://www.terraform.io/docs/cloud/api/workspaces.html#update-a-workspace


# TODO: populate AWS creds, from this workspace's env vars
# https://registry.terraform.io/providers/EppO/environment/latest
# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable

# TODO: TF Variables, from webserver/*.yml
