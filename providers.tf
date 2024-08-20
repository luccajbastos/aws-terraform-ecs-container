provider "aws" {
  region  = lookup(var.project_config, local.env)["aws_region"]
  profile = lookup(var.project_config, local.env)["aws_profile"]
}