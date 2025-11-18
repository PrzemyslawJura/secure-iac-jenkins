resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "${var.project}-vpc" }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false
  tags = { Name = "${var.project}-private-subnet" }
}

# IAM role for EC2 to access a specific S3 bucket (least privilege)
data "aws_iam_policy_document" "app_s3_access" {
  statement {
    sid    = "AllowGetPutListOnSpecificBucket"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.secure_bucket.arn,
      "${aws_s3_bucket.secure_bucket.arn}/*"
    ]
  }
}

resource "aws_iam_role" "app_role" {
  name = "${var.project}-app-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "app_policy" {
  name   = "${var.project}-s3-policy"
  policy = data.aws_iam_policy_document.app_s3_access.json
}

resource "aws_iam_role_policy_attachment" "attach_app" {
  role       = aws_iam_role.app_role.name
  policy_arn = aws_iam_policy.app_policy.arn
}

resource "aws_iam_instance_profile" "app_profile" {
  name = "${var.project}-instance-profile"
  role = aws_iam_role.app_role.name
}

