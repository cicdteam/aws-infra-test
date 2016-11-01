provider "aws" { region = "${var.region}" }

module "network" {
  source          = "modules/network"
  region          = "${var.region}"
  name            = "${var.name}"
  public_key_path = "${var.public_key_path}"
}

module "bastion" {
  name               = "${var.name}-bastion"
  source             = "modules/bastion"
  region             = "${var.region}"
  domain_name        = "${module.network.domain_name}"
  vpc_id             = "${module.network.vpc_id}"
  vpc_cidr           = "${module.network.vpc_cidr}"
  subnet_id          = "${module.network.public_subnet_id}"
  key_name           = "${module.network.key_name}"
  route53_zone_id    = "${module.network.route53_zone_id}"
}
output "bastion_public_ip" {value = "${module.bastion.public_ip}"}

data "template_file" "vpc_config" {
  template = "${file("${path.module}/infra.conf.tmpl")}"
  vars {
    vpc_id           = "${module.network.vpc_id}"
    region           = "${var.region}"
    route53_zoneid   = "${module.network.route53_zone_id}"
    domain           = "${module.network.domain_name}"
    key_name         = "${module.network.key_name}"
    private_key_file = "${var.private_key_path}"
    bastion_pub_ip   = "${module.bastion.public_ip}"
    internal_sg      = "${module.network.internal_sg_name}"
  }
}

resource "null_resource" "vpc_config" {
  provisioner "local-exec" {
    command = "echo \"${data.template_file.vpc_config.rendered}\" > ../${var.vpc_config_file}"
  }
}
