resource "aws_vpc" "main" {
    cidr_block = "${var.AWS_VPC_CIDR_BLOCK}"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    tags {
      Name = "main_vpc"
      Role = "Network"
    }
}

resource "aws_subnet" "frontend" {
    vpc_id = "${var.aws_vpc.main.id}"
    count = "${length(split(",", lookup(var.AVZ, var.AWS_REGION)))}"
    cidr_block = "${cidrsubnet(var.vpc_cidr_block, 8, count.index)}"
    availability_zone = "${element(split(",", lookup(var.AVZ, var.AWS_REGION)), count.index)}"
    tags {
      Name = "frontend-${element(split(",", lookup(var.AVZ, var.AWS_REGION)), count.index)}"
      Role = "Network"
    }
}

resource "aws_subnet" "backend" {
    vpc_id = "${var.aws_vpc.main.id}"
    count = "${length(split(",", lookup(var.AVZ, var.AWS_REGION)))}"
    cidr_block = "${cidrsubnet(var.vpc_cidr_block, 8, count.index)}"
    availability_zone = "${element(split(",", lookup(var.AVZ, var.AWS_REGION)), count.index)}"
    tags {
      Name = "backend-${element(split(",", lookup(var.AVZ, var.AWS_REGION)), count.index)}"
      Role = "Network"
    }
}
