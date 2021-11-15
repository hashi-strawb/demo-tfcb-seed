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



/*
Check our webserver/ dir for YAML files, which will be converted to workspace

Expected Format:

$ cat workspaces/London\ Test.yml
  type:         webserver
  name:         London Test
  region:       london
  image_height: 400
  image_width:  560
  image_type:   cat

*/

locals {
  # A future improvement would filter to only those containing type: webserver
  webserver_workspaces     = [for f in fileset(path.module, "workspaces/*.yml") : yamldecode(file(f))]
  webserver_workspaces_map = { for workspace in toset(local.webserver_workspaces) : workspace.name => workspace }
}

#
# Webserver Workspace
# One per YAML file
#


module "webserver-workspace" {
  depends_on = [
    tfe_registry_module.webserver,
  ]

  source   = "./webserver-workspace"
  for_each = local.webserver_workspaces_map

  tfe_org            = var.tfe_org
  vcs_oauth_token_id = var.vcs_oauth_github

  workspace_name        = "webserver-${replace(each.key, " ", "_")}"
  workspace_description = "Placeholder Webserver - ${each.key}"
  workspace_source_name = "hashi-strawb/demo-tfcb-seed/workspaces/${each.key}"
  workspace_source_url  = "https://github.com/hashi-strawb/demo-tfcb-seed/blob/main/workspaces/${each.key}"

  webserver_type         = each.value["type"]
  webserver_region       = each.value["region"]
  webserver_image_type   = each.value["image_type"]
  webserver_image_height = each.value["image_height"]
  webserver_image_width  = each.value["image_width"]
}
