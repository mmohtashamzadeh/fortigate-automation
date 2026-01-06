#This instantiates the module once per firewall (16 times) without duplicating rule definitions (rules are in locals)

# Create 16 modules from the generated locals.firewalls map
# Each module has its own provider config (inside the module).

module "fortigate" {
  for_each = local.firewalls
  source   = "./modules/fortigate_device"

  hostname = each.value.host
  token    = var.fgt_token
  insecure = var.insecure_tls

  interfaces = each.value.interfaces
  addresses  = each.value.addresses
  services   = each.value.services
  policies   = each.value.policies
}

