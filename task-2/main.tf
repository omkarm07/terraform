# AWS Provider
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.region}"
}

# Create EC2 instance(default configuration)
resource "aws_instance" "ec2" {
  ami           = "ami-013be31976ca2c322"
  instance_type = "t2.micro"

  tags {
    Name = "Lambda-Testing-Server"
  }
}

# CloudWatch Rule
resource "aws_cloudwatch_event_rule" "ec2" {
  name        = "Ec2InstanceState"
  description = "Capture Ec2 Instance State"

  event_pattern = <<PATTERN
  {
    "source": [ "aws.ec2" ],
    "detail-type": [ "EC2 Instance State-change Notification" ],
    "detail": {
      "state": [
        "stopped",
        "terminated"
      ]
    }
  }
PATTERN
}

#CloudWatch Target
resource "aws_cloudwatch_event_target" "sns" {
  target_id = "${aws_cloudwatch_event_rule.ec2.name}"
  rule      = "Ec2InstanceState"
  arn       = "${aws_sns_topic.aws_updates.id}"
}

# SNS Topic Creation
resource "aws_sns_topic" "aws_updates" {
  name         = "Ec2-Updates"
  display_name = "AWSUpdates"
}

#IAM Role for Lambda function
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Creating Role
resource "aws_iam_policy" "policy" {
  name        = "lambda-policy"
  description = "A Lambda policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "sns:Publish",
                "sns:Subscribe",
                "sns:ConfirmSubscription",
                "logs:*",
                "events:*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "lambda-attach" {
  role       = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.policy.arn}"
}

# #Lambda Function Creation
resource "aws_lambda_function" "Ec2InstanceState" {
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.6"
  filename         = "lambda_function.zip"
  function_name    = "Ec2InstanceState"
  source_code_hash = "${base64sha256(file("lambda_function.zip"))}"
}

#Invoke Lambda Function
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.Ec2InstanceState.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.ec2.arn}"

  #qualifier = "${aws_lambda_alias.test_alias.name}"
}
