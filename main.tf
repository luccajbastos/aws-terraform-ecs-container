data "aws_availability_zones" "azs" {}

locals {

  env  = terraform.workspace == "default" ? "dev" : terraform.workspace
  aws_region = lookup(var.project_config, local.env)["aws_region"]
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

module "ecs-cluster" {
  source = "./modules/ecs"

  ecs_cluster_settings = {
    name = local.name
    containerInsights = lookup(var.ecs_config, local.env)["containerInsights"]
    kms_key_arn = lookup(var.ecs_config, local.env)["kms_arn"]
  }

  tags = local.tags
}

module "app-1" {
  source = "./modules/example-app"

  cluster_name = module.ecs-cluster.cluster_name

  app_config = {
    app_name = "example-app"
    region = local.aws_region
    desired_count = 1
    app_port = 80
    launch_type = "FARGATE"
    enable_execute_command = true
    alb_config = {
      hosts = ["app.com.br"]
      priority = 100
      listener_arn = local.env == "prod" ? module.load-balancer.alb_https_listener_arn[0] : module.load-balancer.alb_http_listener_arn[0]
    }
    network_configuration = {
        vpc_id = module.vpc.vpc_id
        subnets = local.env == "prod" ? module.vpc.private_subnets : module.vpc.public_subnets
        security_groups = module.security-groups.application_security_group_id
        assign_public_ip = local.env == "prod" ? false : true
      }
    container_definitions = {
      image = "public.ecr.aws/ecs-sample-image/amazon-ecs-sample:latest"
      cpu = 1024
      memory = 2048
      essential = true
      command = []
      entryPoint = []
      readonlyRootFilesystem = false
      secretsManagerArn = "arn:aws:secretsmanager:us-east-1:988530097210:secret:test/secret-HGQHpl"
      portMappings = [
        {
          containerPort = 80
          hostPort = 80
          protocol = "tcp"
        }
      ]
    }

  }
}