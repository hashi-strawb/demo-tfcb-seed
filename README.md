# Terraform Cloud Seed Config

Configuring Terraform Cloud workspaces with Terraform Cloud, dynamically created
from YAML config files in the `./workspaces` directory.

Example:
```
type:         webserver
name:         lucytest
region:       london
image_height: 400
image_width:  560
image_type:   cat
```

The Terraform config in `main.tf` parses the YAML files in the `./workspaces`
directory and uses the values in this file to create new Workspaces in Terraform
Cloud (via a sub-module `./webserver-module`)

YAML files can be created directly, or via a GitHub Action:

https://github.com/hashi-strawb/demo-tfcb-seed/actions/workflows/create-webserver.yml

Workspaces use Terraform code from the `webserver/main.tf` directory, which will
spin up a placeholder webserver on an EC2 instance in AWS in either London or
Ireland.

## Configuring the Seed Workspace

The Seed workspace must be configured with the following Environment variables:
* `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` - AWS Credentials
* `TFE_TOKEN` A Terraform API Key

## Caveats

This repo is meant as a Proof-of-Concept, rather than intended to be Production
Ready. If you intend to make use of the ideas used in this repo, you are free
to do so on the proviso that you understand how everything works, and fixing
any issues that may arise yourself. While HashiCorp support will be there for
any Terraform Enterprise/Cloud issues, they cannot be expected to understand or
support all possible configurations.

The Terraform code in this repo makes use of the [Multispace Provider](https://registry.terraform.io/providers/mitchellh/multispace/latest/docs),
which allows for Apply/Destroy runs of other workspaces to be run from a main
workspace.

There is [a bug](https://github.com/mitchellh/terraform-provider-multispace/issues/6)
in the provider which means that it does not currently work when Price Estimation
is enabled, nor when there are any Sentinel policies running.

While the provider is written by Mitchell Hashimoto himself, it is also not
officially supported by HashiCorp.

There is also no validation of parameters in the Terraform code, or GitHub Action.
While doable with Terraform, this is considered out-of-scope of this demo.
