provider "google" {
}

resource "random_string" "project_name_service" {
  length           = 8
  special          = false
  upper            = false
  numeric          = false
}

data "google_organization" "default" {
  domain = var.organization_domain
}

module "host-project" {
  source = "../.."
  name = "foobar-project-test"
  parent = data.google_organization.default.id
  billing_account = var.billing_account_id
  shared_vpc_host_config = {
    enabled = true
  }
}

module "service-project" {
  source = "../.."
  name = random_string.project_name_service.result
  parent = data.google_organization.default.id
  billing_account = var.billing_account_id
  shared_vpc_service_config = {
    attach       = true
    host_project = module.host-project.project_id
  }
}