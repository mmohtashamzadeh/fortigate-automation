rules = {
  "ALLOW_WEB_HTTPS" = {
    srcintf = "port1"
    dstintf = "port3"
    srcaddr = ["all"]
    dstaddr = ["WEB_SERVER"]
    service = ["HTTPS"]
    action  = "accept"
    log     = "all"
    nat     = true
  }
}

