terraform {
  required_version = "~> 0.14"
  
  required_providers {
    vault = {
      source = "hashicorp/vault"
      version = "~> 2.19"
    }
  }
}

resource "vault_mount" "this" {
  type = "pki"
  
  path = coalesce(var.path, var.name)
  description = coalesce(var.description, "${var.name} Certificate Authority")
}

resource "vault_pki_secret_backend_root_cert" "this" {
  backend = vault_mount.this.path
  
  type = "internal"
  common_name = vault_mount.this.description
}

resource "vault_pki_secret_backend_config_urls" "this" {
  depends_on = [vault_pki_secret_backend_root_cert.this]
  
  backend = vault_pki_secret_backend_root_cert.this.backend
  
  issuing_certificates = ["./v1/${vault_mount.this.path}/ca"]
  crl_distribution_points = ["./v1/${vault_mount.this.path}/crl"]
}
