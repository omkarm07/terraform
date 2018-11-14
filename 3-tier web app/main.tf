provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.region}"
}

resource "aws_key_pair" "deployer" {
  key_name   = "${var.key_name}"
  public_key = "${file("../aws.pub")}"
}

## Create Application Server in Private Subnet
resource "aws_instance" "application_server" {
  ami                    = "${lookup(var.linux-ami,var.region)}"
  instance_type          = "${var.instance_type}"
  availability_zone      = "${var.private_subnet_avz[0]}"
  vpc_security_group_ids = ["${aws_security_group.appsg.id}"]
  subnet_id              = "${aws_subnet.private_subnet.*.id[0]}"
  key_name               = "${var.key_name}"

  tags {
    Name = "Application Server"
  }
}
