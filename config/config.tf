module "main" {
  source           = "../tf"

  region                 = "${var.region}"
  name                   = "${var.name}"
  public_key_path        = "${var.public_key_path}"
  private_key_path       = "${var.private_key_path}"
  vpc_config_file        = "${var.vpc_config_file}"

}
