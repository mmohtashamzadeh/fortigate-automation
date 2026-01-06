variable "hostname" {
  type = string
}

variable "token" {
  type      = string
  sensitive = true
}

variable "insecure" {
  type = bool
}


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
    srcintf  = string  # "lan" | "wan" | "dmz" (keys in interfaces)
    dstintf  = string
    srcaddr  = list(string)
    dstaddr  = list(string)
    service  = list(string) # built-in or custom
    action   = string       # accept/deny
    nat      = bool
    log      = string       # all/utm/disable (depends on FortiOS)
  }))
}

