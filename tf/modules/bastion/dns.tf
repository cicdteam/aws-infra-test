resource "aws_route53_record" "bastion" {
  zone_id = "${var.route53_zone_id}"
  name    = "bastion"
  type    = "A"
  ttl     = "60"
  records = ["${module.instance.private_ip}"]
  lifecycle { create_before_destroy = true }
}
