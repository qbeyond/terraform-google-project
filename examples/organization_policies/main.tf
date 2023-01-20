provider "google" {
  impersonate_service_account = var.impersonate_service_account
}

resource "random_string" "project_name" {
  length           = 8
  special          = false
  upper            = false
  numeric          = false
}

module "project" {
  source = "../.."
  name = random_string.project_name.result
  parent = var.organization_id
  billing_account = var.billing_account_id
  org_policies_data_path = "configs/"
  services = ["cloudbilling.googleapis.com", "cloudresourcemanager.googleapis.com", "orgpolicy.googleapis.com"]
  org_policies = {
    "compute.disableGuestAttributesAccess" = {
      enforce = true
    }
    "constraints/compute.skipDefaultNetworkCreation" = {
      enforce = true
    }
    "iam.disableServiceAccountKeyCreation" = {
      enforce = false
    }
  }
}