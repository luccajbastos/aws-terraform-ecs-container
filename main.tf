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
    create_efs_security_group = false
  }

  admin_ips = [
    {
      ip = "18.206.107.24/29"
      description = "EC2 Instance Connect range (us-east-1)"
    }
  ]


  tags = local.tags
}

module "load-balancer" {
  depends_on = [module.vpc, module.security-groups]
  source     = "./modules/load-balancer"

  name = local.name

  alb_security_group_id      = module.security-groups.alb_security_group_id
  alb_subnet_ids             = module.vpc.public_subnets
  alb_custom_certificate_arn = lookup(var.alb_configuration, local.env)["alb_custom_certificate_arn"]
  enable_deletion_protection = local.env == "prod" ? true : false

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

  db_parameters = [
    {
      name = "character_set_client"
      value = "utf8"
    },
    {
      name = "character_set_connection"
      value = "utf8"
    },
    {
      name = "character_set_database"
      value = "utf8"
    },
    {
      name = "collation_server"
      value = "utf8mb4_unicode_ci"
    },
    {
      name = "character_set_server"
      value = "utf8mb4"
    }
  ]

  tags = local.tags
}

module "auto-scaling-group" {
  depends_on = [ module.vpc, module.security-groups, module.load-balancer, module.rds-mysql] 
  source = "./modules/ec2-instances"

  name = local.name
  max_capacity = lookup(var.instance, local.env)["max_capacity"]
  min_capacity = lookup(var.instance, local.env)["min_replicas"]
  desired_capacity = lookup(var.instance, local.env)["replicas"]
  security_groups = module.security-groups.application_security_group_id
  associate_public_ip = local.env == "prod" ? false : true
  app_port = lookup(var.instance, local.env)["target_group_port"]
  app_protocol = lookup(var.instance, local.env)["target_group_protocol"]
  app_subnets_ids = local.env == "prod" ? module.vpc.private_subnets : module.vpc.public_subnets
  golden_ami_id = ""
  instance_type = lookup(var.instance, local.env)["instance_type"]
  vpc_id = module.vpc.vpc_id

  health_check_config = {
    enabled = true
    healthy_threshold = 2
    path = "/"
    port = lookup(var.instance, local.env)["target_group_port"]
    protocol = lookup(var.instance, local.env)["target_group_protocol"]
    unhealthy_threshold = 5
    interval = 30
  }

  alb_listener_arn = local.env == "prod" ? module.load-balancer.alb_https_listener_arn[0] : module.load-balancer.alb_http_listener_arn[0]
  alb_rule_priority = 10
  path_patterns = ["/"]

  tags = local.tags

}