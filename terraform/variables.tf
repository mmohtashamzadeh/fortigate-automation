variable "fgt_host" {
  type = string
}

variable "fgt_token" {
  type      = string
  sensitive = true
}

variable "rules" {
  description = "Firewall policy rules to manage (data-driven)."
  type = map(object({
    srcintf = string
    dstintf = string
    srcaddr = list(string)
    dstaddr = list(string)
    service = list(string)
    action  = string
    log     = string
    nat     = bool
  }))
}

