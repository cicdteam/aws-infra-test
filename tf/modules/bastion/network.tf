resource "aws_security_group" "bastion" {
  name        = "${var.name}"
  vpc_id      = "${var.vpc_id}"
  description = "${var.name} security group"
  tags { Name = "${var.name}-sg" }
  lifecycle { create_before_destroy = true }

  ingress { # no limit inside VPC
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["${var.vpc_cidr}"]
  }
  ingress { # SSH
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
