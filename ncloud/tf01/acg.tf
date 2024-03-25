locals {
  default_acg_rules_inbound = [
#    ["TCP", "0.0.0.0/0", "80"],
#    ["TCP", "0.0.0.0/0", "443"],
#    ["TCP", "0.0.0.0/0", "111"],
#    ["TCP", "0.0.0.0/0", "2049"],
#    ["TCP", "0.0.0.0/0", "2379-2380"],
#    ["TCP", "0.0.0.0/0", "6443"],
#    ["TCP", "0.0.0.0/0", "10250-10255"],
#    ["TCP", "0.0.0.0/0", "30000-32767"],
#    ["UDP", "0.0.0.0/0", "4789"],
#    ["TCP", "10.0.1.0/24", "22"],
#    ["TCP", "${var.client_ip}/32", "22"],
#    ["TCP", "${var.client_ip2}/32", "22"],
#    ["TCP", "${var.client_ip3}/32", "22"],
    ["TCP", "0.0.0.0/0", "1-65535"],
    ["UDP", "0.0.0.0/0", "1-65534"],
    ["ICMP", "0.0.0.0/0", null]
  ]

  default_acg_rules_outbound = [
    ["TCP", "0.0.0.0/0", "1-65535"],
    ["UDP", "0.0.0.0/0", "1-65534"],
    ["ICMP", "0.0.0.0/0", null]
  ]
}

resource "ncloud_access_control_group" "acg_scn_01" {
  description = "Access to Cloud2"
  vpc_no      = ncloud_vpc.vpc_scn_01.id
}

resource "ncloud_access_control_group_rule" "acg_rule_scn_01" {
  access_control_group_no = ncloud_access_control_group.acg_scn_01.id

  dynamic "inbound" {
    for_each = local.default_acg_rules_inbound
    content {
      protocol    = inbound.value[0]
      ip_block    = inbound.value[1]
      port_range  = inbound.value[2]
    }
  }

  dynamic "outbound" {
    for_each = local.default_acg_rules_outbound
    content {
      protocol    = outbound.value[0]
      ip_block    = outbound.value[1]
      port_range  = outbound.value[2]
    }
  }
}