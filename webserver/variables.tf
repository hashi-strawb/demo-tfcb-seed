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

