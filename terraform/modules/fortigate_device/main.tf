
# Address objects
resource "fortios_firewall_address" "addr" {
  for_each = var.addresses

  name   = each.key
  type   = "ipmask"
  subnet = each.value.subnet
}

# Custom services (TCP only, demo)
resource "fortios_firewallservice_custom" "svc" {
  for_each = var.services

  name          = each.key
  tcp_portrange = each.value.tcp_portrange
}

# Policies
resource "fortios_firewall_policy" "pol" {
  for_each = var.policies

  name       = each.key
  policyid   = each.value.policyid
  action     = each.value.action
  status     = "enable"
  schedule   = "always"
  logtraffic = each.value.log
  nat        = each.value.nat ? "enable" : "disable"

  srcintf { name = var.interfaces[each.value.srcintf] }
  dstintf { name = var.interfaces[each.value.dstintf] }

  dynamic "srcaddr" {
    for_each = each.value.srcaddr
    content { name = srcaddr.value }
  }

  dynamic "dstaddr" {
    for_each = each.value.dstaddr
    content { name = dstaddr.value }
  }

  dynamic "service" {
    for_each = each.value.service
    content { name = service.value }
  }

  depends_on = [
    fortios_firewall_address.addr,
    fortios_firewallservice_custom.svc
  ]
}

