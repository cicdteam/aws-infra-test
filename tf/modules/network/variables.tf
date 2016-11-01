#
# External vars
#
variable "name" {}
variable "region" {}
variable "public_key_path" {}

#
# Internal vars
#
variable "domain_name" {
  description = "Internal domain name"
  default = "test.local"
}
variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.111.0.0/16"
}
variable "public_subnet_cidr" {
    description = "CIDR for the Public Subnet"
    default = "10.111.111.0/24"
}
variable "private_subnet_cidr" {
    description = "CIDR for the Private Subnet"
    default = "10.111.222.0/24"
}
