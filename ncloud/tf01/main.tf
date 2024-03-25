# VPC > User scenario > Scenario 1. Single Public Subnet
# https://docs.ncloud.com/ko/networking/vpc/vpc_userscenario1.html

provider "ncloud" {
  support_vpc = true
  region      = "KR"
  access_key  = var.access_key
  secret_key  = var.secret_key
  site = "gov"
}

resource "ncloud_login_key" "key_scn_01" {
  key_name = var.server_name01
}

resource "ncloud_vpc" "vpc_scn_01" {
  name            = var.server_name01
  ipv4_cidr_block = "10.0.0.0/16"
}

resource "ncloud_subnet" "subnet_scn_01" {
  name           = var.server_name01
  vpc_no         = ncloud_vpc.vpc_scn_01.id
  subnet         = cidrsubnet(ncloud_vpc.vpc_scn_01.ipv4_cidr_block, 8, 1)
  // 10.0.1.0/24
  zone           = "KR-1"
  network_acl_no = ncloud_vpc.vpc_scn_01.default_network_acl_no
  subnet_type    = "PUBLIC"
  // PUBLIC(Public) | PRIVATE(Private)
}

resource "ncloud_network_interface" "nic01" {
  name                  = "server-nic1"
  description           = "for server-nic"
  subnet_no             = ncloud_subnet.subnet_scn_01.id
  access_control_groups = [ncloud_access_control_group.acg_scn_01.id]
}

resource "ncloud_network_interface" "nic02" {
  name                  = "server-nic2"
  description           = "for server-nic"
  subnet_no             = ncloud_subnet.subnet_scn_01.id
  access_control_groups = [ncloud_access_control_group.acg_scn_01.id]
}

resource "ncloud_network_interface" "nic03" {
  name                  = "server-nic3"
  description           = "for server-nic"
  subnet_no             = ncloud_subnet.subnet_scn_01.id
  access_control_groups = [ncloud_access_control_group.acg_scn_01.id]
}

resource "ncloud_network_interface" "nic04" {
  name                  = "server-nic4"
  description           = "for server-nic"
  subnet_no             = ncloud_subnet.subnet_scn_01.id
  #private_ip            = "10.0.1.6"
  access_control_groups = [ncloud_access_control_group.acg_scn_01.id]
}

resource "ncloud_server" "server_01" {
  subnet_no                 = ncloud_subnet.subnet_scn_01.id
  name                      = var.server_name01
  server_image_product_code = "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"
  login_key_name            = ncloud_login_key.key_scn_01.key_name
  description = "master"
  network_interface {
    network_interface_no = ncloud_network_interface.nic01.id
    order                = 0
  }
}

resource "ncloud_server" "server_02" {
  subnet_no                 = ncloud_subnet.subnet_scn_01.id
  name                      = var.server_name02
  server_image_product_code = "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"
  login_key_name            = ncloud_login_key.key_scn_01.key_name
  network_interface {
    network_interface_no = ncloud_network_interface.nic02.id
    order                = 0
  }
}

resource "ncloud_server" "server_03" {
  subnet_no                 = ncloud_subnet.subnet_scn_01.id
  name                      = var.server_name03
  server_image_product_code = "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"
  login_key_name            = ncloud_login_key.key_scn_01.key_name
  network_interface {
    network_interface_no = ncloud_network_interface.nic03.id
    order                = 0
  }
}

resource "ncloud_server" "server_04" {
  subnet_no                 = ncloud_subnet.subnet_scn_01.id
  name                      = var.server_name04
  server_image_product_code = "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"
  login_key_name            = ncloud_login_key.key_scn_01.key_name
  description = "nfs"
  network_interface {
    network_interface_no = ncloud_network_interface.nic04.id
    order                = 0
  }
}

resource "ncloud_public_ip" "public_ip_01" {
  server_instance_no = ncloud_server.server_01.id
  description        = "for ${var.server_name01}"
}

resource "ncloud_public_ip" "public_ip_02" {
  server_instance_no = ncloud_server.server_02.id
  description        = "for ${var.server_name02}"
}

resource "ncloud_public_ip" "public_ip_03" {
  server_instance_no = ncloud_server.server_03.id
  description        = "for ${var.server_name03}"
}

resource "ncloud_public_ip" "public_ip_04" {
  server_instance_no = ncloud_server.server_04.id
  description        = "for ${var.server_name04}"
}

locals {
  scn01_inbound = [
    [1, "TCP", "0.0.0.0/0", "80", "ALLOW"],
    [2, "TCP", "0.0.0.0/0", "443", "ALLOW"],
    [3, "TCP", "${var.client_ip}/32", "22", "ALLOW"],
    [4, "TCP", "${var.client_ip2}/32", "22", "ALLOW"],
    [5, "TCP", "${var.client_ip3}/32", "22", "ALLOW"],
    [6, "TCP", "0.0.0.0/0", "111", "ALLOW"],
    [7, "TCP", "0.0.0.0/0", "2049", "ALLOW"],
    [8, "TCP", "0.0.0.0/0", "6443", "ALLOW"],
    [9, "TCP", "0.0.0.0/0", "2379-2380", "ALLOW"],
    [10, "TCP", "0.0.0.0/0", "10250-10255", "ALLOW"],
    [11, "UDP", "0.0.0.0/0", "4789", "ALLOW"],
    [12, "TCP", "0.0.0.0/0", "30000-32767", "ALLOW"],
    [197, "TCP", "0.0.0.0/0", "1-65535", "ALLOW"],
    [198, "UDP", "0.0.0.0/0", "1-65535", "ALLOW"],
    [199, "ICMP", "0.0.0.0/0", null, "ALLOW"],
  ]

  scn01_outbound = [
    [1, "TCP", "0.0.0.0/0", "80", "ALLOW"],
    [2, "TCP", "0.0.0.0/0", "443", "ALLOW"],
    [3, "TCP", "${var.client_ip}/32", "1000-65535", "ALLOW"],
    [4, "TCP", "${var.client_ip2}/32", "1000-65535", "ALLOW"],
    [5, "TCP", "${var.client_ip3}/32", "1000-65535", "ALLOW"],
    [6, "TCP", "0.0.0.0/0", "30000-32767", "ALLOW"],
    [7, "UDP", "0.0.0.0/0", "30000-32767", "ALLOW"],
    [197, "TCP", "0.0.0.0/0", "1-65535", "ALLOW"],
    [198, "UDP", "0.0.0.0/0", "1-65535", "ALLOW"],
    [199, "ICMP", "0.0.0.0/0", null, "ALLOW"]
  ]
}

resource "ncloud_network_acl_rule" "network_acl_01_rule" {
  network_acl_no = ncloud_vpc.vpc_scn_01.default_network_acl_no
  dynamic "inbound" {
    for_each = local.scn01_inbound
    content {
      priority    = inbound.value[0]
      protocol    = inbound.value[1]
      ip_block    = inbound.value[2]
      port_range  = inbound.value[3]
      rule_action = inbound.value[4]
      description = "for ${var.server_name01}"
    }
  }

  dynamic "outbound" {
    for_each = local.scn01_outbound
    content {
      priority    = outbound.value[0]
      protocol    = outbound.value[1]
      ip_block    = outbound.value[2]
      port_range  = outbound.value[3]
      rule_action = outbound.value[4]
      description = "for ${var.server_name01}"
    }
  }
}