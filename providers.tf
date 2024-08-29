provider "aws" {
  region  = local.aws_region
  profile = lookup(var.project_config, local.env)["aws_profile"]
}