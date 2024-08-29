resource "aws_iam_policy" "container_policy" {
  name = "${local.container_name}-policy"

    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": [
                    "ssmmessages:CreateControlChannel",
                    "ssmmessages:CreateDataChannel",
                    "ssmmessages:OpenControlChannel",
                    "ssmmessages:OpenDataChannel"
                ],
                "Effect": "Allow",
                "Resource": "*"
            },
            {
                "Action": [
                    "ecr:BatchCheckLayerAvailability",
                    "ecr:BatchGetImage",
                    "ecr:GetDownloadUrlForLayer",
                    "ecr:GetLifecyclePolicy",
                    "ecr:GetAuthorizationToken"
                ],
                "Effect": "Allow",
                "Resource": "*"
            },
            {
                "Action": [
                    "logs:CreateLogStream",
                    "logs:PutLogEvents",
                    "logs:CreateLogGroup"
                ],
                "Effect": "Allow",
                "Resource": "*"
            },
            {
                "Action": [
                    "secretsmanager:GetSecretValue"
                ],
                "Resource": "${var.app_config.container_definitions.secretsManagerArn}",
                "Effect": "Allow"
            }
        ]
    })
}

data "aws_iam_policy_document" "container_trust_relationship_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "container_role" {
  assume_role_policy  = data.aws_iam_policy_document.container_trust_relationship_role.json
  managed_policy_arns = [aws_iam_policy.container_policy.arn]
}