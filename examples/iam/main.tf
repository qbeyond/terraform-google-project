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

resource "google_cloud_identity_group" "basic" {
  parent = "customers/${data.google_organization.default.directory_customer_id}"

  group_key {
      id = "projectmailtest@${data.google_organization.default.domain}"
  }

  labels = {
    "cloudidentity.googleapis.com/groups.discussion_forum" = ""
  }
}

module "project" {
  source = "../.."
  name = random_string.project_name.result
  parent = data.google_organization.default.id
  billing_account = var.billing_account_id
  services = [
    "cloudidentity.googleapis.com"
  ]
  group_iam = {
    "${google_cloud_identity_group.basic.group_key.0.id}" = [
      "roles/cloudasset.owner",
      "roles/cloudsupport.techSupportEditor",
      "roles/iam.securityReviewer",
      "roles/logging.admin"
    ]
  }
}