#
# External vars
#
variable "name" {}
variable "key_name" {}
variable "region" {}
variable "vpc_id" {}
variable "vpc_cidr" {}
variable "subnet_id" {}
variable "route53_zone_id" {}
variable "domain_name" {}

#
# Internal vars
#
variable "ec2type" { default = "t2.nano" }