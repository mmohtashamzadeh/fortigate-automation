provider "fortios" {
  hostname = var.fgt_host
  token    = var.fgt_token
  insecure = true
}

module "policies" {
  source = "./modules/fortigate_policy"
  rules  = var.rules
}

