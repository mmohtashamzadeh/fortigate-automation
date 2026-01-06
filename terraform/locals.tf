#generates a realistic per-firewall config (LAN/DMZ vary by firewall number)

locals {
  # Firewalls FW15..FW30 → 192.168.10.15..30
  firewall_numbers = range(15, 31)

  firewalls = {
    for n in local.firewall_numbers :
    format("FW%02d", n) => {
      host = format("192.168.10.%d", n)

      # "Project-ish" interface naming
      interfaces = {
        lan = "port1"
        wan = "port2"
        dmz = "port3"
      }

      # Per-device subnets
      # FW15: 10.15.0.0/24, 172.16.15.0/24
      addresses = {
        format("LAN_%02d_NET", n) = { subnet = format("10.%d.0.0 255.255.255.0", n) }
        format("DMZ_%02d_NET", n) = { subnet = format("172.16.%d.0 255.255.255.0", n) }
        "ADMIN_NET"               = { subnet = var.admin_net }
        "SIEM_COLLECTOR"          = { subnet = "${var.siem_ip} 255.255.255.255" }
      }

      # Custom services
      services = {
        "TCP_5432_POSTGRES" = { tcp_portrange = "5432" }
        "TCP_3306_MYSQL"    = { tcp_portrange = "3306" }
        "TCP_9200_ELK"      = { tcp_portrange = "9200" }
      }

      # Policies (per device) — similar baseline, with per-device address names
      # Important: FortiGate policy ordering matters → we set policyid explicitly
      policies = {
        # 10 - LAN → WAN web
        format("P%02d_LAN_TO_WAN_WEB", n) = {
          policyid = 10
          srcintf  = "lan"
          dstintf  = "wan"
          srcaddr  = [format("LAN_%02d_NET", n)]
          dstaddr  = ["all"]
          service  = ["HTTP", "HTTPS"]
          action   = "accept"
          nat      = true
          log      = "all"
        }

        # 20 - LAN → WAN DNS
        format("P%02d_LAN_TO_WAN_DNS", n) = {
          policyid = 20
          srcintf  = "lan"
          dstintf  = "wan"
          srcaddr  = [format("LAN_%02d_NET", n)]
          dstaddr  = ["all"]
          service  = ["DNS"]
          action   = "accept"
          nat      = true
          log      = "utm"
        }

        # 30 - LAN → WAN NTP
        format("P%02d_LAN_TO_WAN_NTP", n) = {
          policyid = 30
          srcintf  = "lan"
          dstintf  = "wan"
          srcaddr  = [format("LAN_%02d_NET", n)]
          dstaddr  = ["all"]
          service  = ["NTP"]
          action   = "accept"
          nat      = true
          log      = "all"
        }

        # 40 - DMZ → LAN DB (Postgres)
        format("P%02d_DMZ_TO_LAN_DB", n) = {
          policyid = 40
          srcintf  = "dmz"
          dstintf  = "lan"
          srcaddr  = [format("DMZ_%02d_NET", n)]
          dstaddr  = [format("LAN_%02d_NET", n)]
          service  = ["TCP_5432_POSTGRES"]
          action   = "accept"
          nat      = false
          log      = "all"
        }

        # 50 - LAN → SIEM (Syslog typically UDP/514; we’ll keep it simple with "ALL" or create service later)
        # Here we use built-in "SYSLOG" if present; otherwise swap to "ALL_UDP" or a custom UDP_514 service.
        format("P%02d_LAN_TO_SIEM", n) = {
          policyid = 50
          srcintf  = "lan"
          dstintf  = "wan"
          srcaddr  = [format("LAN_%02d_NET", n)]
          dstaddr  = ["SIEM_COLLECTOR"]
          service  = ["SYSLOG"]
          action   = "accept"
          nat      = false
          log      = "all"
        }

        # 9000 - Default deny (explicit)
        format("P%02d_DEFAULT_DENY", n) = {
          policyid = 9000
          srcintf  = "lan"
          dstintf  = "wan"
          srcaddr  = ["all"]
          dstaddr  = ["all"]
          service  = ["ALL"]
          action   = "deny"
          nat      = false
          log      = "all"
        }
      }
    }
  }
}

