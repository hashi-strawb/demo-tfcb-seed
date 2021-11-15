variable "tfe_org" {
  type    = string
  default = "fancycorp"
}

#
# VCS Config
#

variable "vcs_oauth_token_id" {
  type    = string
  default = ""
}
variable "workspace_vcs_identifier" {
  type    = string
  default = "hashi-strawb/demo-tfcb-seed"
}
variable "workspace_vcs_branch" {
  type    = string
  default = "main"
}
variable "workspace_working_directory" {
  type    = string
  default = "webserver"
}


#
# Workspace Config
#

variable "workspace_name" {
  type    = string
  default = "test"
}
variable "workspace_description" {
  type    = string
  default = "Placeholder Webserver - test"
}
variable "workspace_source_name" {
  type    = string
  default = ""
}
variable "workspace_source_url" {
  type    = string
  default = ""
}

#
# Webserver Config
#

variable "webserver_type" {
  type    = string
  default = "webserver"
}
variable "webserver_region" {
  type    = string
  default = "london"
}
variable "webserver_image_type" {
  type    = string
  default = "cat"
}
variable "webserver_image_height" {
  type    = string
  default = "400"
}
variable "webserver_image_width" {
  type    = string
  default = "560"
}
