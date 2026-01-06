variable "interfaces" {
  type = object({
    lan = string
    wan = string
    dmz = string
  })
}

variable "addresses" {
  type = map(object({
    subnet = string
  }))
}

variable "services" {
  type = map(object({
    tcp_portrange = string
  }))
}

variable "policies" {
  type = map(object({
    policyid = number
    srcintf  = string
    dstintf  = string
    srcaddr  = list(string)
    dstaddr  = list(string)
    service  = list(string)
    action   = string
    nat      = bool
    log      = string
  }))
}

