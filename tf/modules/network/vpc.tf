#
# Define AWS Virtual Private Cloud
#
resource "aws_vpc" "local" {
  depends_on           = ["aws_vpc_dhcp_options.local"]
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags { Name          = "${var.name}-vpc" }
  lifecycle { create_before_destroy = true }
}
output "vpc_id"            {value = "${aws_vpc.local.id}"}
output "vpc_cidr"          {value = "${var.vpc_cidr}"}
output "domain_name"       {value = "${var.domain_name}"}

#
# Define AWS Private Subnet
#
resource "aws_subnet" "private" {
  vpc_id            = "${aws_vpc.local.id}"
  cidr_block        = "${var.private_subnet_cidr}"
  tags { Name       = "${var.name}-private" }
  lifecycle { create_before_destroy = true }
  map_public_ip_on_launch = false
}
output "private_subnet_id" {value = "${aws_subnet.private.id}"}

#
# Define AWS Public Subnet
#
resource "aws_subnet" "public" {
  vpc_id            = "${aws_vpc.local.id}"
  cidr_block        = "${var.public_subnet_cidr}"
  tags { Name       = "${var.name}-public" }
  lifecycle { create_before_destroy = true }
  map_public_ip_on_launch = true
}
output "public_subnet_id" {value = "${aws_subnet.public.id}"}

#
# Define Internet Gateway
#
resource "aws_internet_gateway" "public" {
  vpc_id      = "${aws_vpc.local.id}"
  tags { Name = "${var.name}-gw-public" }
  lifecycle { create_before_destroy = true }
}

#
# Define an EIP for the NAT Gateway
#
resource "aws_eip" "nat" {
  depends_on = ["aws_subnet.private", "aws_subnet.public"]
  vpc        = true
  provisioner "local-exec" { command  = "echo Waiting 60 seconds for EIP to propagate; sleep 60" }
  lifecycle { create_before_destroy = true }
}
output "nat_ip" {value = "${aws_eip.nat.public_ip}"}

#
# Define a NAT Gateway to route all outbound traffic
#
resource "aws_nat_gateway" "nat" {
  depends_on    = ["aws_internet_gateway.public", "aws_subnet.private"]
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public.id}"
  lifecycle { create_before_destroy = true }
}

#
# Define route tables fro private and public subnets
#
resource "aws_route_table" "public" {
  vpc_id       = "${aws_vpc.local.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.public.id}"
  }
  tags { Name  = "${var.name}-table-public" }
  lifecycle { create_before_destroy = true }
}
resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
  lifecycle { create_before_destroy = true }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.local.id}"
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat.id}"
  }
  tags { Name = "${var.name}-table-private" }
  lifecycle { create_before_destroy = true }
}
resource "aws_route_table_association" "private" {
  subnet_id      = "${aws_subnet.private.id}"
  route_table_id = "${aws_route_table.private.id}"
  lifecycle { create_before_destroy = true }
}

#
# Set Route53 resources
#
resource "aws_route53_zone" "local" {
  name          = "${var.domain_name}"
  vpc_id        = "${aws_vpc.local.id}"
  lifecycle { create_before_destroy = true }
}
output "route53_zone_id" { value = "${aws_route53_zone.local.id}" }

resource "aws_vpc_dhcp_options" "local" {
  domain_name          = "${var.domain_name}"
  domain_name_servers  = ["AmazonProvidedDNS"]
  tags { Name          = "${var.name}"}
  lifecycle { create_before_destroy = true }
  provisioner "local-exec" { command = "echo Waiting 30 seconds for DHCP Options to propagate; sleep 30" }
}

resource "aws_vpc_dhcp_options_association" "local" {
  vpc_id           = "${aws_vpc.local.id}"
  dhcp_options_id  = "${aws_vpc_dhcp_options.local.id}"
  lifecycle { create_before_destroy = true }
}
