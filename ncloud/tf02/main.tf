provider "ncloud" {
  support_vpc = true
  region      = "KR"
  access_key  = var.access_key
  secret_key  = var.secret_key
  site        = "gov"
}

module "instance" {
  source = "./module"

  machines = var.machines
  client_ip = var.client_ip
}
