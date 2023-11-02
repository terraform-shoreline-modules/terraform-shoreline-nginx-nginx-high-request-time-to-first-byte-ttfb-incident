terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "high_nginx_request_time_to_first_byte_ttfb_incident" {
  source    = "./modules/high_nginx_request_time_to_first_byte_ttfb_incident"

  providers = {
    shoreline = shoreline
  }
}