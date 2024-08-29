terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    profile        = "lucca-aws"
    region         = "us-east-1"
    key            = "ecs/terraform.state"
    bucket         = "lucca-backend"
    dynamodb_table = "lucca-lock-table"
  }
}

