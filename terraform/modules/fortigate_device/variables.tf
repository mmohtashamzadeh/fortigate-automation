variable "fgt_token" {
  description = "FortiGate API token (demo assumes same token for all devices)"
  type        = string
  sensitive   = true
}

variable "insecure_tls" {
  description = "Skip TLS verification for FortiGate API"
  type        = bool
  default     = true
}

# Shared “project” parameters
variable "project" {
  type    = string
  default = "corp-sec-fw-automation"
}

variable "siem_ip" {
  type    = string
  default = "10.99.10.50"
}

variable "admin_net" {
  type    = string
  default = "10.99.0.0 255.255.0.0"
}
