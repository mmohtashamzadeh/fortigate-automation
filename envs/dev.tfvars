rules = {
  "ALLOW_APP_TO_DB_5432" = {
    srcintf = "port1"
    dstintf = "port2"
    srcaddr = ["SRC_APP_NET"]
    dstaddr = ["DST_DB_NET"]
    service = ["POSTGRES"]
    action  = "accept"
    log     = "all"
    nat     = false
  }
}

