# Project: High Availability (HA) and Single AZ AWS Environments with Terraform Workspaces

This project is designed to showcase how Terraform can be used to provision AWS environments tailored to specific needs using Terraform workspaces. The configurations are managed centrally in the **variables.tf** file, allowing for streamlined management across different environments.

![Production Environment Diagram](/assets/production-environment.jpg "Production Environment Diagram")

# Overview

The project demonstrates the creation of two distinct AWS environments using Terraform:

 - Production Environment: Built for high availability and reliability, suitable for production workloads.
 - Development Environment: Optimized for minimal cost, ideal for development and testing purposes.

# Key Features

 1. Terraform Workspaces: Enables the management of multiple environments (e.g., production, development) within the same configuration, reducing duplication and simplifying maintenance.
 2. Automated Provisioning: With a single command, the entire infrastructure is provisioned or updated, ensuring consistency and repeatability.
 3. Environment-Specific Configuration: Each workspace has environment-specific settings, ensuring that resources are appropriately scaled and configured according to the environment's needs.

# Cost Warning

**Important:** Deploying any of the environments in this project will incur costs on your AWS account. The exact amount will depend on the resources provisioned and the duration of their usage. It is recommended to review the AWS pricing page and monitor your usage through the AWS Billing Dashboard.

# Production Environment (HA)

The production environment is designed with a focus on high availability and reliability, using managed services that offer these features wherever possible. The key components include:

- **Amazon RDS for MySQL:** Multi-AZ deployment with deletion protection enabled.
- **Auto Scaling Group:** Configured with 3 instances, scaling up to a maximum of 5.
- **Application Load Balancer:** Deletion protection enabled.

To deploy this environment, create and select the **prod** workspace:
```shell
    terraform workspace new prod
    terraform workspace select prod
    terraform apply -auto-approve
```

![Production Environment Diagram](/assets/production-environment.jpg "Production Environment Diagram")

# Development Environment (Single AZ and Cost-Optimized)

The development environment is designed to be cost-effective while providing the necessary resources for development and testing. It uses a Single Availability Zone (AZ) setup to minimize costs, with managed services to reduce operational overhead.

- **Amazon RDS for MySQL:** Single AZ deployment to reduce costs.\
- **Auto Scaling Group:** Configured to start with 1 instance, scaling up to 2 if needed.\

To deploy this environment, create and select the **dev** workspace:
```shell
    terraform workspace new dev
    terraform workspace select dev
    terraform apply -auto-approve
```

![Development Environment Diagram](/assets/development-environment.png "Development Environment Diagram")

# Getting Started

## Prerequisites

 1. Terraform: Ensure that Terraform is installed on your machine. You can download it from the official Terraform website.
 2. AWS Account: You will need an AWS account with sufficient permissions to create and manage resources.
 3. AWS CLI: Installing the AWS CLI can help with managing your AWS environment from the command line.

## Setup

1. Clone the Repository:

```shell
    git clone https://github.com/yourusername/terraform-aws-environment.git
    cd terraform-aws-environment
```
2. Configure AWS Credentials:
Make sure your AWS credentials are configured either via the AWS CLI or by setting environment variables.

```shell
    aws configure sso --profile <profile-name>
```

3. Initialize Terraform:

```shell
    terraform init
```

# Contributing
Contributions are welcome! Please fork the repository and submit a pull request for any improvements or bug fixes.

# License
This project is licensed under the MIT License. See the LICENSE file for details.



