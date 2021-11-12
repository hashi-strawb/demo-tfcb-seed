variable "ami_name" {
  type        = string
  default     = "strawbtest/demo/webserver"
  description = "Which AMI should we use?"
}

variable "ami_version" {
  type        = string
  default     = "v0.1.0"
  description = "Which version of the AMI should we use?"
}



variable "image_type" {
  type        = string
  default     = "cat"
  description = "Type of image to show"
}
variable "image_width" {
  type        = string
  default     = "560"
  description = "Width of image"
}
variable "image_height" {
  type        = string
  default     = "400"
  description = "Height of image"
}
variable "region" {
  type        = string
  default     = "london"
  description = "Which region to deploy the webserver into"
}
