terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.26.0"
    }
  }
}

# Auth is read from the CLOUDFLARE_API_TOKEN environment variable.
provider "cloudflare" {}
