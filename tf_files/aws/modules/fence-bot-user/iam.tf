

# Fence bot

## Fence bot user
resource "aws_iam_user" "fence-bot" {
  name = "${var.vpc_name}_fence-bot"
}

## Fence bot key/secret
resource "aws_iam_access_key" "fence-bot_user_key" {
  user = "${aws_iam_user.fence-bot.name}"
}

## Fence bot access policy
resource "aws_iam_user_policy" "fence-bot_policy" {
  name = "${var.vpc_name}_fence-bot_policy"
  user = "${aws_iam_user.fence-bot.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Effect": "Allow",
      "Resource": ["${data.aws_s3_bucket.data-bucket.arn}/*"]
    }
  ]
}
EOF
}

