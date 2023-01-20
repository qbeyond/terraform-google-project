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

resource "google_tags_tag_key" "default" {
  parent = data.google_organization.default.id
  short_name = "keyname"
  description = "For keyname resources."
}

resource "google_tags_tag_value" "default" {
    parent = google_tags_tag_key.default.id
    short_name = "valuename"
    description = "For valuename resources."
}

module "project" {
  source = "../.."
  name = random_string.project_name.result
  parent = data.google_organization.default.id
  billing_account = var.billing_account_id
  tag_bindings = {
    foo = google_tags_tag_value.default.id
  }
}