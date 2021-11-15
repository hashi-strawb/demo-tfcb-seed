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