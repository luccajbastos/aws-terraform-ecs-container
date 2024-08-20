data "aws_availability_zones" "azs" {}

locals {

  env  = terraform.workspace == "default" ? "dev" : terraform.workspace
  name = "${var.project_name}-${local.env}"

  tags = {
    Environment = local.env
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }

  azs             = slice(data.aws_availability_zones.azs.names, 0, lookup(var.vpc_configuration, local.env)["number_azs"])
  cidr            = lookup(var.vpc_configuration, local.env)["cidr"]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.cidr, 4, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.cidr, 4, k + 3)]
  data_subnets    = [for k, v in local.azs : cidrsubnet(local.cidr, 4, k + 6)]

}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"

  name = "${local.name}-vpc"
  azs  = local.azs
  cidr = local.cidr

  private_subnets  = local.private_subnets
  public_subnets   = local.public_subnets
  database_subnets = local.data_subnets

  database_subnet_group_name = "${local.name}-db-subnet-group"

  enable_nat_gateway = lookup(var.vpc_configuration, local.env)["enable_nat"]
  single_nat_gateway = lookup(var.vpc_configuration, local.env)["single_nat"]

  tags = local.tags

}

module "security-groups" {
  depends_on = [module.vpc]
  source     = "./modules/security-groups"

  name          = local.name
  vpc_cidr      = module.vpc.vpc_cidr_block
  vpc_id        = module.vpc.vpc_id
  database_port = 3306

  config = {
    create_alb_security_group = true
    create_app_security_group = true
    create_db_security_group  = true
    create_efs_security_group = true
  }

  admin_ips = {
    entry = {
      ip = "177.143.109.94/32"
      description = "Lucca pessoal IP"
    }
  }

  tags = local.tags
}

module "load-balancer" {
  depends_on = [module.vpc, module.security-groups]
  source     = "./modules/load-balancer"

  name = local.name

  alb_security_group_id      = module.security-groups.alb_security_group_id
  alb_subnet_ids             = module.vpc.public_subnets
  alb_custom_certificate_arn = lookup(var.alb_configuration, local.env)["alb_custom_certificate_arn"]

  environment     = local.env
  enable_alb_logs = lookup(var.alb_configuration, local.env)["enable_logs"]

  tags = local.tags

}

module "monitoring" {
  source = "./modules/monitoring"
}

module "rds-mysql" {
  source     = "./modules/rds-mysql"
  depends_on = [module.vpc, module.security-groups]

  name        = var.project_name
  environment = local.env

  instance_class      = lookup(var.db_instance, local.env)["instance_class"]
  deletion_protection = lookup(var.db_instance, local.env)["deletion_protection"]
  ha                  = lookup(var.db_instance, local.env)["ha"]
  allocated_storage   = lookup(var.db_instance, local.env)["allocated_storage"]
  subnet_group_name   = module.vpc.database_subnet_group_name
  events_sns_topic    = module.monitoring.db_topic_arn
  security_groups = module.security-groups.db_security_group_id

  tags = local.tags
}

module "elastic-file-system" {
  depends_on = [module.vpc, module.security-groups]
  source     = "./modules/elastic-file-system"

  name    = local.name
  subnets = module.vpc.private_subnets
  security_groups_ids = module.security-groups.efs_security_group_id
  tags    = local.tags
}

module "auto-scaling-group" {
  depends_on = [ module.vpc, module.security-groups, module.load-balancer, module.rds-mysql, module.elastic-file-system] 
  source = "./modules/ec2-instances"

  name = local.name
  max_capacity = lookup(var.instance, local.env)["replicas"]
  min_capacity = lookup(var.instance, local.env)["min_replicas"]
  app_port = lookup(var.instance, local.env)["target_group_port"]
  app_protocol = lookup(var.instance, local.env)["target_group_protocol"]
  app_subnets_ids = module.vpc.private_subnets
  golden_ami_id = lookup(var.instance, local.env)["golden_ami_id"]
  instance_type = lookup(var.instance, local.env)["instance_type"]
  vpc_id = module.vpc.vpc_id

  golden_ec2_config = {
    create = lookup(var.instance, local.env)["golden_ec2"]["create_golden_ec2"]
    security_groups = module.security-groups.application_security_group_id
    subnet_id = module.vpc.public_subnets[0]
    key_name = lookup(var.instance, local.env)["golden_ec2"]["pem_key_name"]
  }

  health_check_config = {
    enabled = true
    healthy_threshold = 2
    path = "/health-check"
    port = lookup(var.instance, local.env)["target_group_port"]
    protocol = lookup(var.instance, local.env)["target_group_protocol"]
    unhealthy_threshold = 5
    interval = 30
  }

  tags = local.tags

}