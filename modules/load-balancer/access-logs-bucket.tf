locals {
  alb_region = data.aws_region.current.name

  alb_logs_id = {
    us-east-1      = "127311923021"
    us-east-2      = "033677994240"
    us-west-1      = "027434742980"
    us-west-2      = "797873946194"
    af-south-1     = "098369216593"
    ap-southeast-3 = "754344448648"
    ap-southeast-4 = "589379963580"
    ap-south-1     = "718504428378"
    ap-northeast-3 = "383597477331"
    ap-northeast-2 = "600734575887"
    ap-southeast-1 = "114774131450"
    ap-southeast-2 = "783225319266"
    ap-northeast-1 = "582318560864"
    ca-central-1   = "985666609251"
    eu-central-1   = "054676820928"
    eu-west-1      = "156460612806"
    eu-west-2      = "635631232127"
    eu-west-3      = "897822967062"
    eu-north-1     = "011223344556"
    me-south-1     = "076674570225"
    sa-east-1      = "507241528517"
  }

}

resource "random_pet" "alb" {
  prefix    = "logs"
  separator = "-"
}

locals {
  enable_alb_logs = var.enable_alb_logs ? true : false
}


resource "aws_s3_bucket" "alb_logs_bucket" {
  depends_on = [random_pet.alb]
  count      = local.enable_alb_logs ? 1 : 0
  bucket     = "${lower(local.alb_name)}-${random_pet.alb.id}"

  force_destroy = true
}


resource "aws_s3_bucket_policy" "attachment_policy" {
  depends_on = [aws_s3_bucket.alb_logs_bucket]
  count      = local.enable_alb_logs ? 1 : 0
  bucket     = aws_s3_bucket.alb_logs_bucket[0].id
  policy     = data.aws_iam_policy_document.alb_logs_bucket_policy[0].json
}

data "aws_iam_policy_document" "alb_logs_bucket_policy" {
  count      = local.enable_alb_logs ? 1 : 0
  depends_on = [aws_s3_bucket.alb_logs_bucket]
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${lookup(local.alb_logs_id, local.alb_region)}:root"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      aws_s3_bucket.alb_logs_bucket[0].arn,
      "${aws_s3_bucket.alb_logs_bucket[0].arn}/*",
    ]
  }
}