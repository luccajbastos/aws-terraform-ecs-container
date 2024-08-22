variable "project_name" {
  type    = string
  default = "ha-environment"
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

variable "db_instance" {
  type = object({
    prod = object({
      ha                  = bool
      instance_class      = string
      deletion_protection = bool
      allocated_storage   = number
    })
    dev = object({
      ha                  = bool
      instance_class      = string
      deletion_protection = bool
      allocated_storage   = number
    })
  })

  default = {

    prod = {
      ha                  = true
      instance_class      = "db.t4g.medium"
      deletion_protection = true
      allocated_storage   = 50
    }

    dev = {
      ha                  = false
      instance_class      = "db.t4g.small"
      deletion_protection = false
      allocated_storage   = 20
    }
  }
}

variable "instance" {

  type = object({
    prod = object({
      type     = string
      replicas = number
      min_replicas = number
      max_capacity = number
      target_group_port = number
      target_group_protocol = string
      golden_ami_id = string
      instance_type = string

    })

    dev = object({
      type     = string
      replicas = number
      max_capacity = number
      min_replicas = number
      target_group_port = number
      target_group_protocol = string
      
      golden_ami_id = string
      instance_type = string

    })
  })

  default = {

    prod = {
      type     = "t4g.medium"
      replicas = 3
      max_capacity = 5
      min_replicas = 1
      target_group_port = 80
      target_group_protocol = "HTTP"
      golden_ami_id = ""
      instance_type = "t3.medium"

    }

    dev = {
      type     = "t4g.micro"
      replicas = 1
      max_capacity = 2
      min_replicas = 1
      target_group_port = 80
      target_group_protocol = "HTTP"
      golden_ami_id = ""
      instance_type = "t3.small"

    }

  }

}