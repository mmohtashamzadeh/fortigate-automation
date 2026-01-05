terraform {
  required_version = ">= 1.5.0"
  required_providers {
    fortios = {
      source  = "fortinetdev/fortios"
      version = ">= 1.20.0"
    }
  }
}

