terraform {
  required_version = "~> 0.14"
  
  required_providers {
    vault = {
      source = "hashicorp/vault"
      version = "~> 2.19"
    }
  }
}

locals {
  path = coalesce(var.path, var.name)
  description = coalesce(var.description, "${var.name} Certificate Authority")
  urls_prefix = var.urls_prefix
  
  issuing_certificates = [ for url in local.urls_prefix: "${url}/v1/pippo/ca" ]
}

resource "vault_mount" "this" {
  type = "pki"
  
  path = local.path
  description = local.description
}

resource "vault_pki_secret_backend_root_cert" "this" {
  depends_on = [vault_mount.this]
  
  backend = vault_mount.this.path
  
  type = "internal"
  common_name = vault_mount.this.description
}

resource "vault_pki_secret_backend_config_urls" "this" {
  depends_on = [vault_pki_secret_backend_root_cert.this]
  
  backend = vault_pki_secret_backend_root_cert.this.backend
  
  #issuing_certificates = toset([ for url in local.urls_prefix: "${url}/v1/${vault_mount.this.path}/ca" ])
  #crl_distribution_points = toset([ for url in local.urls_prefix: "${url}/v1/${vault_mount.this.path}/crl"]
  issuing_certificates = [ for url in local.urls_prefix: "${url}/v1/${vault_mount.this.path}/ca" ]
}
