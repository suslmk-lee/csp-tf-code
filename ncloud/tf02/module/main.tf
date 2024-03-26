resource "ncloud_login_key" "loginkey" {
  key_name = "kpaas-key"
}

resource "ncloud_vpc" "vpc" {
  name            = "kpaas-vpc"
  ipv4_cidr_block = "10.0.0.0/16"
}

resource "ncloud_subnet" "subnet" {
  name           = "kpaas-subnet"
  vpc_no         = ncloud_vpc.vpc.id
  subnet         = cidrsubnet(ncloud_vpc.vpc.ipv4_cidr_block, 8, 1)
  zone           = "KR-1"
  network_acl_no = ncloud_vpc.vpc.default_network_acl_no
  subnet_type    = "PUBLIC"
}

resource "ncloud_network_interface" "nic" {
  count = length(var.machines)
  name                  = var.machines[count.index].name
  description           = "for server-nic"
  subnet_no             = ncloud_subnet.subnet.id
  access_control_groups = [ncloud_access_control_group.kpaas_acg.id]
}

resource "ncloud_server" "server" {
  count = length(var.machines)
  subnet_no                 = ncloud_subnet.subnet.id
  name                      = var.machines[count.index].name
  server_image_product_code = var.machines[count.index].server_image_product_code
  login_key_name            = ncloud_login_key.loginkey.key_name
  description               = var.machines[count.index].description
  network_interface {
    network_interface_no = ncloud_network_interface.nic[count.index].id
    order                = 0
  }
}

resource "ncloud_public_ip" "public_ip_01" {
  count = length(var.machines)
  server_instance_no = ncloud_server.server[count.index].id
  description        = "for ${ncloud_server.server[count.index].name}"
}

locals {
  scn01_inbound = [
    [1, "TCP", "0.0.0.0/0", "80", "ALLOW"],
    [2, "TCP", "0.0.0.0/0", "443", "ALLOW"],
    [3, "TCP", "${var.client_ip[0]}/32", "22", "ALLOW"],
    [4, "TCP", "${var.client_ip[1]}/32", "22", "ALLOW"],
    [5, "TCP", "${var.client_ip[2]}/32", "22", "ALLOW"],
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
    [3, "TCP", "${var.client_ip[0]}/32", "1000-65535", "ALLOW"],
    [4, "TCP", "${var.client_ip[1]}/32", "1000-65535", "ALLOW"],
    [5, "TCP", "${var.client_ip[2]}/32", "1000-65535", "ALLOW"],
    [6, "TCP", "0.0.0.0/0", "30000-32767", "ALLOW"],
    [7, "UDP", "0.0.0.0/0", "30000-32767", "ALLOW"],
    [197, "TCP", "0.0.0.0/0", "1-65535", "ALLOW"],
    [198, "UDP", "0.0.0.0/0", "1-65535", "ALLOW"],
    [199, "ICMP", "0.0.0.0/0", null, "ALLOW"]
  ]
}

resource "ncloud_network_acl_rule" "network_acl_01_rule" {
  network_acl_no = ncloud_vpc.vpc.default_network_acl_no
  dynamic "inbound" {
    for_each = local.scn01_inbound
    content {
      priority    = inbound.value[0]
      protocol    = inbound.value[1]
      ip_block    = inbound.value[2]
      port_range  = inbound.value[3]
      rule_action = inbound.value[4]
      description = ""
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
      description = ""
  }
}
}