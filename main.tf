terraform {
  required_providers {
    tfe = {
      version = "~> 0.26.0"
    }
    multispace = {
      source  = "mitchellh/multispace"
      version = "0.1.0"
    }
    environment = {
      source  = "EppO/environment"
      version = "1.1.0"
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

#
# Webserver Module
#

resource "tfe_registry_module" "webserver" {
  vcs_repo {
    display_identifier = "hashi-strawb/terraform-aws-webserver"
    identifier         = "hashi-strawb/terraform-aws-webserver"
    oauth_token_id     = var.vcs_oauth_github
  }
}



#
# Webserver Workspace
# One per YAML file
#

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
  organization = var.tfe_org
  tag_names = [
    yamldecode(file(each.key))["type"],
    yamldecode(file(each.key))["region"],
    yamldecode(file(each.key))["image_type"],
  ]
  auto_apply = false


  vcs_repo {
    identifier     = "hashi-strawb/demo-tfcb-seed"
    oauth_token_id = var.vcs_oauth_github
    branch         = "main"
  }
  working_directory = "webserver"


  # TODO: set this to False when we use multispace
  #  queue_all_runs = false
}

# TODO: update the workspace with a PATCH, to set source-url and source-name:
# https://www.terraform.io/docs/cloud/api/workspaces.html#update-a-workspace

#
# Variables for the Workspace
# Pull from YAML files
#

resource "tfe_variable" "webserver-image_height" {
  for_each     = local.webserver_workspace_files
  workspace_id = tfe_workspace.webserver[each.key].id

  key         = "image_height"
  value       = yamldecode(file(each.key))["image_height"]
  category    = "terraform"
  description = "height of image"
}
resource "tfe_variable" "webserver-image_width" {
  for_each     = local.webserver_workspace_files
  workspace_id = tfe_workspace.webserver[each.key].id

  key         = "image_width"
  value       = yamldecode(file(each.key))["image_width"]
  category    = "terraform"
  description = "width of image"
}
resource "tfe_variable" "webserver-image_type" {
  for_each     = local.webserver_workspace_files
  workspace_id = tfe_workspace.webserver[each.key].id

  key         = "image_type"
  value       = yamldecode(file(each.key))["image_type"]
  category    = "terraform"
  description = "type of image"
}
resource "tfe_variable" "webserver-region" {
  for_each     = local.webserver_workspace_files
  workspace_id = tfe_workspace.webserver[each.key].id

  key         = "region"
  value       = yamldecode(file(each.key))["region"]
  category    = "terraform"
  description = "region to deploy webserver into"
}


#
# Pass Through AWS Creds
# For a demo, this is fine
# In Production, you would want each workspace to have its own creds
# e.g. by authenticating with Vault
#

data "environment_variables" "aws" {
  filter = "AWS_"
}
resource "tfe_variable" "webserver-aws_access_key_id" {
  for_each     = local.webserver_workspace_files
  workspace_id = tfe_workspace.webserver[each.key].id

  key         = "AWS_ACCESS_KEY_ID"
  value       = data.environment_variables.aws.items["AWS_ACCESS_KEY_ID"]
  category    = "env"
  description = "AWS Access Key ID"
}
resource "tfe_variable" "webserver-aws_secret_access_key" {
  for_each     = local.webserver_workspace_files
  workspace_id = tfe_workspace.webserver[each.key].id

  key         = "AWS_SECRET_ACCESS_KEY"
  value       = data.environment_variables.aws.items["AWS_SECRET_ACCESS_KEY"]
  category    = "env"
  description = "AWS Secret Access Key"
  sensitive   = true
}
resource "tfe_variable" "webserver-aws_session_token" {
  for_each     = local.webserver_workspace_files
  workspace_id = tfe_workspace.webserver[each.key].id

  key         = "AWS_SESSION_TOKEN"
  value       = data.environment_variables.aws.items["AWS_SESSION_TOKEN"]
  category    = "env"
  description = "AWS Session Token"
  sensitive   = true
}



# Currently doesn't place nice with cost estimation & policy checks
# i.e. https://github.com/mitchellh/terraform-provider-multispace/issues/6
/*
provider "multispace" {}
# Trigger a plan+apply on apply, and a destroy on destroy

resource "time_sleep" "wait_10_seconds" {
  depends_on = [tfe_workspace.webserver]

  create_duration = "10s"
}
resource "multispace_run" "webserver" {

  depends_on = [
    # Naturally depends on our webserver workspace existing
    tfe_workspace.webserver,

    # And wait at least 10s to ensure that it's created before we attempt to run
    time_sleep.wait_10_seconds,

    # or our TF module
    # tfe_registry_module.webserver,
  ]
  for_each     = local.webserver_workspace_files
  workspace    = "webserver-${replace(yamldecode(file(each.key))["name"], " ", "_")}"
  organization = var.tfe_org

  #  retry = false
  #  manual_confirm = true
}]
*/


# TODO: populate AWS creds, from this workspace's env vars
# https://registry.terraform.io/providers/EppO/environment/latest
# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable

