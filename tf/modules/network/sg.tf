resource "aws_security_group" "internal" {
  name        = "${var.name}-internal-sg"
  vpc_id      = "${aws_vpc.local.id}"
  description = "${var.name} internal security group"
  tags { Name = "${var.name}-internal-sg" }
  lifecycle { create_before_destroy = true }

  ingress { # no limit inside VPC
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["${var.vpc_cidr}"]
  }
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "internal_sg_name"  {value = "${aws_security_group.internal.name}"}
output "internal_sg_id"    {value = "${aws_security_group.internal.id}"}
