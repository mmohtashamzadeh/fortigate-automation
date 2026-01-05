variable "rules" {
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

