variable "project_name" {
  type    = string
  default = "ecs-environment"
}

variable "project_config" {

  type = object({
    prod = object({
      aws_profile = string
      aws_region  = string
    })

    dev = object({
      aws_profile = string
      aws_region  = string
    })
  })

  default = {
    prod = {
      aws_profile = "lucca-aws"
      aws_region  = "us-east-1"
    }

    dev = {
      aws_profile = "lucca-aws"
      aws_region  = "us-east-1"
    }
  }
}

variable "vpc_configuration" {
  type = object({
    prod = object({
      cidr       = string
      single_nat = bool
      enable_nat = bool
      number_azs = number
    })

    dev = object({
      cidr       = string
      single_nat = bool
      enable_nat = bool
      number_azs = number
    })
  })

  default = {
    prod = {
      cidr       = "10.100.0.0/16"
      single_nat = false
      enable_nat = true
      number_azs = 3
    }

    dev = {
      cidr       = "10.101.0.0/16"
      single_nat = false
      enable_nat = false
      number_azs = 2
    }
  }
}

variable "alb_configuration" {
  type = object({
    prod = object({
      enable_logs                = bool
      alb_custom_certificate_arn = string
    })

    dev = object({
      enable_logs                = bool
      alb_custom_certificate_arn = string
    })
  })

  default = {

    prod = {
      enable_logs                = true
      alb_custom_certificate_arn = "arn:aws:acm:us-east-1:988530097210:certificate/e0a4f9f6-ada6-4eb2-8858-cfe6f5d22e05"
    }

    dev = {
      enable_logs                = false
      alb_custom_certificate_arn = ""
    }
  }

}


variable "ecs_config" {
  type = object({
    prod = object({
      containerInsights = bool
      kms_arn           = string
    })
    dev = object({
      containerInsights = bool
      kms_arn           = string
    })
  })

  default = {
    prod = {
      containerInsights = true
      kms_arn           = null
    }

    dev = {
      containerInsights = false
      kms_arn           = null
    }
  }
}