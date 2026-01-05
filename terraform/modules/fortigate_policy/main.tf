resource "fortios_firewall_policy" "rules" {
  for_each = var.rules

  name       = each.key
  action     = each.value.action
  status     = "enable"
  schedule   = "always"
  logtraffic = each.value.log
  nat        = each.value.nat ? "enable" : "disable"

  srcintf { name = each.value.srcintf }
  dstintf { name = each.value.dstintf }

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
}

