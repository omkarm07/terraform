variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "region" {
  default = "us-east-1"
}

#data "aws_availability_zones" "all" {}

variable "public_subnet_avz" {
  type    = "list"
  default = ["us-east-1a", "us-east-1b"]
}

variable "private_subnet_avz" {
  type    = "list"
  default = ["us-east-1c", "us-east-1d"]
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_cidr" {
  type    = "list"
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_cidr" {
  type    = "list"
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "all_cidr" {
  default = "0.0.0.0/0"
}

variable "linux-ami" {
  type = "map"

  default = {
    us-east-1 = "ami-0922553b7b0369273"
    eu-west-1 = "ami-0c21ae4a3bd190229"
  }
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  description = "Name of AWS key pair"
  default     = "aws"
}

variable "asg_min" {
  description = "Min numbers of servers in ASG"
  default     = "2"
}

variable "asg_max" {
  description = "Max numbers of servers in ASG"
  default     = "5"
}

variable "asg_desired" {
  description = "Desired numbers of servers in ASG"
  default     = "3"
}
