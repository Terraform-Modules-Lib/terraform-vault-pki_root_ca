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
