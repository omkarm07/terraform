## Create RDS Instance
resource "aws_db_instance" "mydb1" {
  engine                  = "mysql"
  engine_version          = "5.7.19"
  multi_az                = false
  storage_type            = "gp2"
  allocated_storage       = 20
  backup_retention_period = 0
  name                    = "login"
  username                = "omkar"
  password                = "Canopy1!"
  port                    = "3306"
  instance_class          = "db.t2.micro"
  publicly_accessible     = false
  skip_final_snapshot     = true
  vpc_security_group_ids  = ["${aws_security_group.mydb1.id}"]
  db_subnet_group_name    = "${aws_db_subnet_group.default.id}"

  tags {
    Name = "DB Instance"
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = ["${aws_subnet.private_subnet.*.id}"]

  tags {
    Name = "My DB subnet group"
  }
}

resource "aws_security_group" "mydb1" {
  name = "mydb1"

  description = "RDS MySQL servers (terraform-managed)"
  vpc_id      = "${aws_vpc.vpc.id}"

  # Only postgres in
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["${var.private_cidr}"]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "Database Sg"
  }
}
