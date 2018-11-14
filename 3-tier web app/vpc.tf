# VPC Creation
resource "aws_vpc" "vpc" {
  cidr_block       = "${var.vpc_cidr}"
  instance_tenancy = "default"

  tags {
    Name = "Dynamic VPC"
  }
}

# SUBNET Creation
#Public Subnet
resource "aws_subnet" "public_subnet" {
  count                   = "${length(var.public_subnet_avz)}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${element(var.public_cidr,count.index)}"
  map_public_ip_on_launch = true
  availability_zone       = "${element(var.public_subnet_avz,count.index)}"

  tags {
    Name = "Public Subnet-${count.index+1}"
  }
}

#Private Subnet
resource "aws_subnet" "private_subnet" {
  count                   = "${length(var.private_subnet_avz)}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${element(var.private_cidr,count.index)}"
  map_public_ip_on_launch = false
  availability_zone       = "${element(var.private_subnet_avz,count.index)}"

  tags {
    Name = "Private Subnet-${count.index+1}"
  }
}

#INTERNET GATEWAY creation
resource "aws_internet_gateway" "ig" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "CustomIG"
  }
}

#PUBLIC Route Table creation
resource "aws_route_table" "rt" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "${var.all_cidr}"
    gateway_id = "${aws_internet_gateway.ig.id}"
  }

  tags {
    Name = "Public Route Table"
  }
}

#Route Table association
resource "aws_route_table_association" "rta" {
  count          = "${length("${var.public_subnet_avz}")}"
  subnet_id      = "${element(aws_subnet.public_subnet.*.id,count.index)}"
  route_table_id = "${aws_route_table.rt.id}"
}

## Create Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  vpc = true
}

## Associate NAT Gateway to Private Subnet
resource "aws_nat_gateway" "gw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public_subnet.*.id[0]}"

  tags {
    Name = "gw NAT"
  }
}

# Create Private Route Table
resource "aws_route_table" "prt" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block     = "${var.all_cidr}"
    nat_gateway_id = "${aws_nat_gateway.gw.id}"
  }

  tags {
    Name = "Private Route Table"
  }
}

## Associate Route Table with Private Subnets
resource "aws_route_table_association" "prta" {
  count          = "${length("${var.private_subnet_avz}")}"
  subnet_id      = "${element(aws_subnet.private_subnet.*.id,count.index)}"
  route_table_id = "${aws_route_table.prt.id}"
}
