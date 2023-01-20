provider "google" {
}

resource "random_string" "project_name" {
  length           = 8
  special          = false
  upper            = false
  numeric          = false
}

resource "random_string" "keyring" {
  length           = 8
  special          = false
  upper            = false
  numeric          = false
}

resource "random_string" "key" {
  length           = 8
  special          = false
  upper            = false
  numeric          = false
}

data "google_organization" "default" {
  domain = var.organization_domain
}

resource "google_kms_key_ring" "default" {
  name     = random_string.keyring.result
  location = "europe"
  project = var.kms_project_id
}

resource "google_kms_crypto_key" "default" {
  name            = random_string.key.result
  key_ring        = google_kms_key_ring.default.id
}

module "project" {
  source = "../.."
  name = random_string.project_name.result
  parent = data.google_organization.default.id
  billing_account = var.billing_account_id
  services = [
    "compute.googleapis.com"
  ]
  service_encryption_key_ids = {
    compute = [
      "projects/${var.kms_project_id}/locations/europe/keyRings/${random_string.keyring.result}/cryptoKeys/${random_string.key.result}"
    ]
  }
}