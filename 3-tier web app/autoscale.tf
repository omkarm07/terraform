## Create Auto Scaling Group
resource "aws_autoscaling_group" "web-asg" {
  name                 = "terraform-autoscaling"
  max_size             = "${var.asg_max}"
  min_size             = "${var.asg_min}"
  desired_capacity     = "${var.asg_desired}"
  health_check_type    = "ELB"
  force_delete         = true
  launch_configuration = "${aws_launch_configuration.web-lc.name}"
  load_balancers       = ["${aws_elb.web-elb.name}"]
  vpc_zone_identifier  = ["${aws_subnet.public_subnet.*.id}"]

  #vpc_zone_identifier = ["${split(",", var.availability_zones)}"]
  tag {
    key                 = "Name"
    value               = "web-asg"
    propagate_at_launch = "true"
  }
}

## Launch Configuration
resource "aws_launch_configuration" "web-lc" {
  name            = "launch-config-terraform"
  image_id        = "${lookup(var.linux-ami, var.region)}"
  instance_type   = "${var.instance_type}"
  security_groups = ["${aws_security_group.websg.id}"]
  user_data       = "${file("userdata.sh")}"
  key_name        = "${var.key_name}"

  lifecycle {
    create_before_destroy = true
  }
}
