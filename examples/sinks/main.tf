provider "google" {
}

resource "random_string" "project_name" {
  length           = 8
  special          = false
  upper            = false
  numeric          = false
}

resource "random_string" "bucket_name" {
  length           = 8
  special          = false
  upper            = false
  numeric          = false
}


data "google_organization" "default" {
  domain = var.organization_domain
}

resource "google_storage_bucket" "default" {
  name          = random_string.bucket_name.result
  location      = "EU"
  force_destroy = true
  project       = var.bucket_project_id
}

module "project" {
  source = "../.."
  name = random_string.project_name.result
  parent = data.google_organization.default.id
  billing_account = var.billing_account_id
  logging_sinks = {
    debug = {
      project       = var.bucket_project_id
      destination   = google_storage_bucket.default.id
      filter        = "severity=DEBUG"
      type          = "storage"
      unique_writer = true
    }
  }
}