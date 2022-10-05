resource "random_uuid" "generator" {
}

resource "aws_s3_bucket" "central_logging" {
  bucket        = "central-logging-${random_uuid.generator.id}"
  force_destroy = true
  tags = {
    Account           = var.account
    terraform-managed = "true"
  }
}

resource "aws_s3_bucket_acl" "central_logging" {
  bucket = aws_s3_bucket.central_logging.id
  acl    = "private"
}

resource "aws_cloudwatch_log_group" "central_logging" {
  name = "CentralLoggingCWGroup"
  tags = {
    Account           = var.account
    terraform-managed = "true"
  }
}

resource "aws_iam_role" "cloud_trail_assume_role_cw" {
  name               = "CloudTrailAssumeRoleCloudWatch"
  assume_role_policy = <<-EOF
   {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "cloudtrail.amazonaws.com"
          },
          "Effect": "Allow"
        }
      ]
   }
  EOF
}

resource "aws_iam_policy" "cloud_trail_assume_role_cw_policy" {
  name        = "CloudTrailAssumeRoleCloudWatchPolicy"
  description = "policy for cloud trail to send events to cloudwatch log groups"
  policy      = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream"
            ],
            "Resource": [
              "${aws_cloudwatch_log_group.central_logging.arn}:*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents"
            ],
            "Resource": [
              "${aws_cloudwatch_log_group.central_logging.arn}:*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:GetRole",
                "iam:PassRole"
            ],
            "Resource": [
              "${aws_iam_role.cloud_trail_assume_role_cw.arn}"
            ]
        }        
      ]
    }
  EOF
}

resource "aws_iam_role_policy_attachment" "cloudtrail-cloudwatch-role-policy-attachment" {
  role       = aws_iam_role.cloud_trail_assume_role_cw.name
  policy_arn = aws_iam_policy.cloud_trail_assume_role_cw_policy.arn
}

resource "aws_s3_bucket_policy" "central_logging_bucket_policy" {
  bucket = aws_s3_bucket.central_logging.id

  policy = <<-POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "cloudtrail.amazonaws.com"
        },
        "Action": "s3:GetBucketAcl",
        "Resource": "arn:aws:s3:::${aws_s3_bucket.central_logging.id}"
      },
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "cloudtrail.amazonaws.com"
        },
        "Action": "s3:PutObject",
        "Resource": "arn:aws:s3:::${aws_s3_bucket.central_logging.id}/trails/AWSLogs/*",
        "Condition": {
          "StringEquals": {
            "s3:x-amz-acl": "bucket-owner-full-control"
          }
        }
      }
    ]
  }
  POLICY
}

# Create an Admin Role with CW Administrator Access Policy
module "assume_admin_role" {
  source = "./modules/assumerolepolicytrust"

  role_name      = "AssumeRoleAdmin${var.account}"
  trusted_entity = "arn:aws:iam::${var.identity_account_id}:root"
  policy_arn     = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  account        = var.account

}