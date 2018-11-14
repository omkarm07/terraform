## Create ELB
resource "aws_elb" "web-elb" {
  name            = "terraform-example-elb"
  security_groups = ["${aws_security_group.websg.id}"]
  subnets         = ["${aws_subnet.public_subnet.*.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:80"
    interval            = 10
  }

  tags {
    Name = "Classic ELB"
  }
}
