data "template_file" "init" {
  template = "${file("${path.module}/templates/host.init.tmpl")}"
  vars {
    hostname = "bastion"
    domain   = "${var.domain_name}"
  }
}

module "instance" {
  source             = "../ec2"
  region             = "${var.region}"
  instance_name      = "${var.name}"
  instance_type      = "${var.ec2type}"
  key_name           = "${var.key_name}"
  subnet_id          = "${var.subnet_id}"
  security_group_ids = "${aws_security_group.bastion.id}"
  user_data          = "${data.template_file.init.rendered}"
}

output "public_ip"  {value = "${module.instance.public_ip}"}
output "private_ip" {value = "${module.instance.private_ip}"}
