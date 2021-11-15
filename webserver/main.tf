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
  count = var.region == "london" ? 1 : 0

  source  = "app.terraform.io/fancycorp/webserver/aws"
  version = "0.5.1"

  providers = {
    aws = aws.london
  }

  ami_name = "${var.ami_name}/${var.ami_version}"

  image_type   = var.image_type
  image_width  = var.image_width
  image_height = var.image_height
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
  count = var.region == "ireland" ? 1 : 0

  source  = "app.terraform.io/fancycorp/webserver/aws"
  version = "0.5.1"

  providers = {
    aws = aws.ireland
  }

  ami_name = "${var.ami_name}/${var.ami_version}"

  image_type   = var.image_type
  image_width  = var.image_width
  image_height = var.image_height
}
