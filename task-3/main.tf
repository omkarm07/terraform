provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.region}"
}

#Create S3 Bucket
resource "aws_s3_bucket" "examplebucket" {
  bucket = "<bucket_name>"
  acl    = "private"
}

#S3 Bucket Policy Using JSON File
resource "aws_s3_bucket_policy" "policy" {
  bucket = "${aws_s3_bucket.examplebucket.id}"
  policy = "${file("s3_policy.json")}"
}

# Another Way to Create Policy
# resource "aws_s3_bucket_policy" "policy" {
#   bucket = "${aws_s3_bucket.examplebucket.id}"
#   policy = <<POLICY
# {
#     "Version": "2012-10-17",
#     "Id": "PutObjPolicy",
#     "Statement": [
#         {
#             "Sid": "DenyIncorrectEncryptionHeader",
#             "Effect": "Deny",
#             "Principal": "*",
#             "Action": "s3:PutObject",
#             "Resource": "arn:aws:s3:::<bucket_name>/*",
#             "Condition": {
#                 "StringNotEquals": {
#                     "s3:x-amz-server-side-encryption": "AES256"
#                 }
#             }
#         },
#         {
#             "Sid": "DenyUnEncryptedObjectUploads",
#             "Effect": "Deny",
#             "Principal": "*",
#             "Action": "s3:PutObject",
#             "Resource": "arn:aws:s3:::<bucket_name>/*",
#             "Condition": {
#                 "Null": {
#                     "s3:x-amz-server-side-encryption": "true"
#                 }
#             }
#         },
#         {
#             "Sid": "DenyIncorrectEncryptionHeader",
#             "Effect": "Deny",
#             "Principal": "*",
#             "Action": "s3:PutObject",
#             "Resource": "arn:aws:s3:::<bucket_name>/*",
#             "Condition": {
#                 "StringNotEquals": {
#                     "s3:x-amz-server-side-encryption": "aws:kms"
#                 }
#             }
#         },
#         {
#             "Sid": "DenyUnEncryptedObjectUploads",
#             "Effect": "Deny",
#             "Principal": "*",
#             "Action": "s3:PutObject",
#             "Resource": "arn:aws:s3:::<bucket_name>/*",
#             "Condition": {
#                 "Null": {
#                     "s3:x-amz-server-side-encryption": "true"
#                  }
#              }
#         }
#     ]
# }
# POLICY
#}

