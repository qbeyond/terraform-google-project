provider "google" {
}

resource "random_string" "project_name" {
  length           = 8
  special          = false
  upper            = false
  numeric          = false
}

data "google_organization" "default" {
  domain = var.organization_domain
}

module "project" {
  source = "../.."
  name = random_string.project_name.result
  parent = data.google_organization.default.id
  billing_account = var.billing_account_id
}