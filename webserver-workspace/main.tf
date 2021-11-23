terraform {
  required_providers {
    tfe = {
      version = "~> 0.26.0"
    }
    multispace = {
      #      source = "mitchellh/multispace"
      # Use my fork until https://github.com/mitchellh/terraform-provider-multispace/pull/8 is merged
      source  = "lucymhdavies/multispace"
      version = "0.2.0-alpha5"
    }

    environment = {
      source  = "EppO/environment"
      version = "1.1.0"
    }
  }
}

resource "tfe_workspace" "webserver" {
  # In reality, you would want some kind of validation here
  # e.g. to check values exist, set default values if they don't,
  # check that values are from a specific list, etc.
  #
  # See https://lmhd.me/tech/2021/05/26/dynamic-terraform/ for an example

  # Replace spaces with underscores in workspace name
  name = var.workspace_name

  description  = var.workspace_description
  organization = var.tfe_org
  tag_names = [
    "type:${var.webserver_type}",
    "region:${var.webserver_region}",
    "imagetype:${var.webserver_image_type}",
  ]
  auto_apply = true


  vcs_repo {
    identifier     = var.workspace_vcs_identifier
    oauth_token_id = var.vcs_oauth_token_id
    branch         = var.workspace_vcs_branch
  }
  working_directory = var.workspace_working_directory


  queue_all_runs = false


  # TODO: Workspace Source
  # Not yet supported by the provider
  # https://github.com/hashicorp/terraform-provider-tfe/issues/392
  # var.workspace_source_name
  # var.workspace_source_url
}



#
# Variables for the Workspace
# Pull from YAML files
#

resource "tfe_variable" "webserver-image_height" {
  workspace_id = tfe_workspace.webserver.id

  key         = "image_height"
  value       = var.webserver_image_height
  category    = "terraform"
  description = "height of image"
}
resource "tfe_variable" "webserver-image_width" {
  workspace_id = tfe_workspace.webserver.id

  key         = "image_width"
  value       = var.webserver_image_width
  category    = "terraform"
  description = "width of image"
}
resource "tfe_variable" "webserver-image_type" {
  workspace_id = tfe_workspace.webserver.id

  key         = "image_type"
  value       = var.webserver_image_type
  category    = "terraform"
  description = "type of image"
}
resource "tfe_variable" "webserver-region" {
  workspace_id = tfe_workspace.webserver.id

  key         = "region"
  value       = var.webserver_region
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
  workspace_id = tfe_workspace.webserver.id

  key         = "AWS_ACCESS_KEY_ID"
  value       = data.environment_variables.aws.items["AWS_ACCESS_KEY_ID"]
  category    = "env"
  description = "AWS Access Key ID"
}
resource "tfe_variable" "webserver-aws_secret_access_key" {
  workspace_id = tfe_workspace.webserver.id

  key         = "AWS_SECRET_ACCESS_KEY"
  value       = data.environment_variables.aws.items["AWS_SECRET_ACCESS_KEY"]
  category    = "env"
  description = "AWS Secret Access Key"
  sensitive   = true
}
resource "tfe_variable" "webserver-aws_session_token" {
  workspace_id = tfe_workspace.webserver.id

  key         = "AWS_SESSION_TOKEN"
  value       = data.environment_variables.aws.items["AWS_SESSION_TOKEN"]
  category    = "env"
  description = "AWS Session Token"
  sensitive   = true
}



# Currently doesn't place nice with cost estimation & policy checks
# i.e. https://github.com/mitchellh/terraform-provider-multispace/issues/6
# Trigger a plan+apply on apply, and a destroy on destroy

resource "time_sleep" "wait_some_seconds" {
  depends_on = [
    # Ensure that we have our TF Vars in place before we trigger a run
    tfe_variable.webserver-aws_access_key_id,
    tfe_variable.webserver-aws_secret_access_key,
    tfe_variable.webserver-aws_session_token,
    tfe_variable.webserver-image_height,
    tfe_variable.webserver-image_width,
    tfe_variable.webserver-image_type,
    tfe_variable.webserver-region,
  ]

  # Wait 30s as a workaround for
  # https://github.com/mitchellh/terraform-provider-multispace/issues/9
  create_duration = "30s"
}
resource "multispace_run" "webserver" {
  depends_on = [
    # And wait at least 10s to ensure that it's created before we attempt to run
    # I'm not entirely sure why this is really needed, but it seems to help
    time_sleep.wait_some_seconds,
  ]

  workspace    = tfe_workspace.webserver.name
  organization = var.tfe_org
}

