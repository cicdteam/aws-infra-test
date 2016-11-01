module "ubuntu" {
  source = "../ubuntu.images"
  region = "${var.region}"
}

resource "aws_instance" "instance" {
  ami                    = "${module.ubuntu.ami_id}"
  key_name               = "${var.key_name}"
  instance_type          = "${var.instance_type}"
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = ["${split(",", var.security_group_ids)}"]
  monitoring             = false
  user_data              = "${var.user_data}"
  tags { Name            = "${var.instance_name}" }
}
output "id"         { value = "${aws_instance.instance.id}" }
output "private_ip" { value = "${aws_instance.instance.private_ip}" }
output "public_ip"  { value = "${aws_instance.instance.public_ip}" }
