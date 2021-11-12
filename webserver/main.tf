terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "fancycorp"

    workspaces {
      prefix = "webserver-"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Random pet for now.
# Real example will spin up a webserver using the
# https://github.com/hashi-strawb/terraform-aws-webserver module
resource "random_pet" "server" {
}


# We will be spinning up resources in AWS
# Define the AWS provider, and add tags that will propagate to all resources
#
# Credentials not defined here. Get them with Doormat:
#
provider "aws" {
  default_tags {
    tags = {
      Name      = "StrawbTest"
      Owner     = "lucy.davinhart@hashicorp.com"
      Purpose   = "Terraform TFC Demo Org (FancyCorp)"
      TTL       = "24h"
      Terraform = "true"
      Source    = "https://github.com/hashi-strawb/demo-tfcb-seed/tree/main/webserver"
    }
  }
  alias  = "london"
  region = "eu-west-2"
}

module "webserver-london" {
  source  = "app.terraform.io/fancycorp/webserver/aws"
  version = "0.3.0"

  providers = {
    aws = aws.london
  }

  ami_name = "${var.ami_name}/${var.ami_version}"
}



# Another AWS provider, in a different region
provider "aws" {
  default_tags {
    tags = {
      Name      = "StrawbTest"
      Owner     = "lucy.davinhart@hashicorp.com"
      Purpose   = "Terraform TFC Demo Org (FancyCorp)"
      TTL       = "24h"
      Terraform = "true"
      Source    = "https://github.com/hashi-strawb/demo-tfcb-seed/tree/main/webserver"
    }
  }
  alias  = "ireland"
  region = "eu-west-1"
}

module "webserver-ireland" {
  count = 0

  source  = "app.terraform.io/fancycorp/webserver/aws"
  version = "0.3.0"

  providers = {
    aws = aws.ireland
  }

  ami_name = "${var.ami_name}/${var.ami_version}"
}
