<!-- BEGIN_TF_DOCS -->
## Usage

# Project Module

This module implements the creation and management of one GCP project including IAM, organization policies, Shared VPC host or service attachment, service API activation, and tag attachment.
It also offers a convenient way to refer to managed service identities (aka robot service accounts) for APIs.

## Examples

### Basic

This Module creates a GCP Project
```hcl
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
variable "organization_domain" {
  type = string
}

variable "billing_account_id" {
  type = string
}
```

### Cloud KMS encryption keys

The module offers a simple, centralized way to assign `roles/cloudkms.cryptoKeyEncrypterDecrypter` to service identities.
```hcl
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
variable "organization_domain" {
  type = string
}

variable "billing_account_id" {
  type = string
}

variable "kms_project_id" {
  type = string
}
```
### IAM

IAM is managed via several variables that implement different levels of control:

- `group_iam` and `iam` configure authoritative bindings that manage individual roles exclusively, mapping to the [`google_project_iam_binding`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam#google_project_iam_binding) resource
- `iam_additive` and `iam_additive_members` configure additive bindings that only manage individual role/member pairs, mapping to the [`google_project_iam_member`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam#google_project_iam_member) resource

Be mindful about service identity roles when using authoritative IAM, as you might inadvertently remove a role from a [service identity](https://cloud.google.com/iam/docs/service-accounts#google-managed) or default service account. For example, using `roles/editor` with `iam` or `group_iam` will remove the default permissions for the Cloud Services identity. A simple workaround for these scenarios is described below.
```hcl
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
variable "organization_domain" {
  type = string
}

variable "billing_account_id" {
  type = string
}
```

### Organization policies

To manage organization policies, the `orgpolicy.googleapis.com` service should be enabled in the quota project.
To use yaml config, it is required to create a yaml file with your configuration and add the org_policies_data_path variable.

```yaml
compute.disableGuestAttributesAccess:
  enforce: true
constraints/compute.skipDefaultNetworkCreation:
  enforce: true
iam.disableServiceAccountKeyCreation:
  enforce: true
iam.disableServiceAccountKeyUpload:
  enforce: false
  rules:
  - condition:
      description: test condition
      expression: resource.matchTagId("tagKeys/1234", "tagValues/1234")
      location: somewhere
      title: condition
    enforce: true
```

```hcl
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
variable "organization_id" {
  type = string
}

variable "billing_account_id" {
  type = string
}

variable "impersonate_service_account" {
  type = string  
}
```



### Shared VPC service

The module allows managing Shared VPC status for both hosts and service projects, and includes a simple way of assigning Shared VPC roles to service identities.
```hcl
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
variable "organization_domain" {
  type = string
}

variable "billing_account_id" {
  type = string
}
```

### Logging Sinks

This Module creates a GCP Project with sink for logging
```hcl
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
variable "organization_domain" {
  type = string
}

variable "billing_account_id" {
  type = string
}

variable "bucket_project_id" {
  type = string
}
```

### Tags

Refer to the [Creating and managing tags](https://cloud.google.com/resource-manager/docs/tags/tags-creating-and-managing) documentation for details on usage.
```hcl
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
variable "organization_domain" {
  type = string
}

variable "billing_account_id" {
  type = string
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.1 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.40.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 4.40.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Project name and id suffix. | `string` | n/a | yes |
| <a name="input_auto_create_network"></a> [auto\_create\_network](#input\_auto\_create\_network) | Whether to create the default network for the project. | `bool` | `false` | no |
| <a name="input_billing_account"></a> [billing\_account](#input\_billing\_account) | Billing account id. | `string` | `null` | no |
| <a name="input_contacts"></a> [contacts](#input\_contacts) | List of essential contacts for this resource. Must be in the form EMAIL -> [NOTIFICATION\_TYPES]. Valid notification types are ALL, SUSPENSION, SECURITY, TECHNICAL, BILLING, LEGAL, PRODUCT\_UPDATES. | `map(list(string))` | `{}` | no |
| <a name="input_custom_roles"></a> [custom\_roles](#input\_custom\_roles) | Map of role name => list of permissions to create in this project. | `map(list(string))` | `{}` | no |
| <a name="input_default_service_account"></a> [default\_service\_account](#input\_default\_service\_account) | Project default service account setting: can be one of `delete`, `deprivilege`, `disable`, or `keep`. | `string` | `"keep"` | no |
| <a name="input_descriptive_name"></a> [descriptive\_name](#input\_descriptive\_name) | Name of the project name. Used for project name instead of `name` variable. | `string` | `null` | no |
| <a name="input_group_iam"></a> [group\_iam](#input\_group\_iam) | Authoritative IAM binding for organization groups, in {GROUP\_EMAIL => [ROLES]} format. Group emails need to be static. Can be used in combination with the `iam` variable. | `map(list(string))` | `{}` | no |
| <a name="input_iam"></a> [iam](#input\_iam) | IAM bindings in {ROLE => [MEMBERS]} format. | `map(list(string))` | `{}` | no |
| <a name="input_iam_additive"></a> [iam\_additive](#input\_iam\_additive) | IAM additive bindings in {ROLE => [MEMBERS]} format. | `map(list(string))` | `{}` | no |
| <a name="input_iam_additive_members"></a> [iam\_additive\_members](#input\_iam\_additive\_members) | IAM additive bindings in {MEMBERS => [ROLE]} format. This might break if members are dynamic values. | `map(list(string))` | `{}` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Resource labels. | `map(string)` | `{}` | no |
| <a name="input_lien_reason"></a> [lien\_reason](#input\_lien\_reason) | If non-empty, creates a project lien with this description. | `string` | `""` | no |
| <a name="input_logging_exclusions"></a> [logging\_exclusions](#input\_logging\_exclusions) | Logging exclusions for this project in the form {NAME -> FILTER}. | `map(string)` | `{}` | no |
| <a name="input_logging_sinks"></a> [logging\_sinks](#input\_logging\_sinks) | Logging sinks to create for this project. | <pre>map(object({<br>    bq_partitioned_table = optional(bool)<br>    description          = optional(string)<br>    destination          = string<br>    disabled             = optional(bool, false)<br>    exclusions           = optional(map(string), {})<br>    filter               = string<br>    iam                  = optional(bool, true)<br>    type                 = string<br>    unique_writer        = optional(bool)<br>  }))</pre> | `{}` | no |
| <a name="input_metric_scopes"></a> [metric\_scopes](#input\_metric\_scopes) | List of projects that will act as metric scopes for this project. | `list(string)` | `[]` | no |
| <a name="input_org_policies"></a> [org\_policies](#input\_org\_policies) | Organization policies applied to this project keyed by policy name. | <pre>map(object({<br>    inherit_from_parent = optional(bool) # for list policies only.<br>    reset               = optional(bool)<br><br>    # default (unconditional) values<br>    allow = optional(object({<br>      all    = optional(bool)<br>      values = optional(list(string))<br>    }))<br>    deny = optional(object({<br>      all    = optional(bool)<br>      values = optional(list(string))<br>    }))<br>    enforce = optional(bool, true) # for boolean policies only.<br><br>    # conditional values<br>    rules = optional(list(object({<br>      allow = optional(object({<br>        all    = optional(bool)<br>        values = optional(list(string))<br>      }))<br>      deny = optional(object({<br>        all    = optional(bool)<br>        values = optional(list(string))<br>      }))<br>      enforce = optional(bool, true) # for boolean policies only.<br>      condition = object({<br>        description = optional(string)<br>        expression  = optional(string)<br>        location    = optional(string)<br>        title       = optional(string)<br>      })<br>    })), [])<br>  }))</pre> | `{}` | no |
| <a name="input_org_policies_data_path"></a> [org\_policies\_data\_path](#input\_org\_policies\_data\_path) | Path containing org policies in YAML format. | `string` | `null` | no |
| <a name="input_oslogin"></a> [oslogin](#input\_oslogin) | Enable OS Login. | `bool` | `false` | no |
| <a name="input_oslogin_admins"></a> [oslogin\_admins](#input\_oslogin\_admins) | List of IAM-style identities that will be granted roles necessary for OS Login administrators. | `list(string)` | `[]` | no |
| <a name="input_oslogin_users"></a> [oslogin\_users](#input\_oslogin\_users) | List of IAM-style identities that will be granted roles necessary for OS Login users. | `list(string)` | `[]` | no |
| <a name="input_parent"></a> [parent](#input\_parent) | Parent folder or organization in 'folders/folder\_id' or 'organizations/org\_id' format. | `string` | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Optional prefix used to generate project id and name. | `string` | `null` | no |
| <a name="input_project_create"></a> [project\_create](#input\_project\_create) | Create project. When set to false, uses a data source to reference existing project. | `bool` | `true` | no |
| <a name="input_service_config"></a> [service\_config](#input\_service\_config) | Configure service API activation. | <pre>object({<br>    disable_on_destroy         = bool<br>    disable_dependent_services = bool<br>  })</pre> | <pre>{<br>  "disable_dependent_services": false,<br>  "disable_on_destroy": false<br>}</pre> | no |
| <a name="input_service_encryption_key_ids"></a> [service\_encryption\_key\_ids](#input\_service\_encryption\_key\_ids) | Cloud KMS encryption key in {SERVICE => [KEY\_URL]} format. | `map(list(string))` | `{}` | no |
| <a name="input_service_perimeter_bridges"></a> [service\_perimeter\_bridges](#input\_service\_perimeter\_bridges) | Name of VPC-SC Bridge perimeters to add project into. See comment in the variables file for format. | `list(string)` | `null` | no |
| <a name="input_service_perimeter_standard"></a> [service\_perimeter\_standard](#input\_service\_perimeter\_standard) | Name of VPC-SC Standard perimeter to add project into. See comment in the variables file for format. | `string` | `null` | no |
| <a name="input_services"></a> [services](#input\_services) | Service APIs to enable. | `list(string)` | `[]` | no |
| <a name="input_shared_vpc_host_config"></a> [shared\_vpc\_host\_config](#input\_shared\_vpc\_host\_config) | Configures this project as a Shared VPC host project (mutually exclusive with shared\_vpc\_service\_project). | <pre>object({<br>    enabled          = bool<br>    service_projects = optional(list(string), [])<br>  })</pre> | `null` | no |
| <a name="input_shared_vpc_service_config"></a> [shared\_vpc\_service\_config](#input\_shared\_vpc\_service\_config) | Configures this project as a Shared VPC service project (mutually exclusive with shared\_vpc\_host\_config). | <pre>object({<br>    host_project         = string<br>    service_identity_iam = optional(map(list(string)))<br>  })</pre> | `null` | no |
| <a name="input_skip_delete"></a> [skip\_delete](#input\_skip\_delete) | Allows the underlying resources to be destroyed without destroying the project itself. | `bool` | `false` | no |
| <a name="input_tag_bindings"></a> [tag\_bindings](#input\_tag\_bindings) | Tag bindings for this project, in key => tag value id format. | `map(string)` | `null` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_custom_roles"></a> [custom\_roles](#output\_custom\_roles) | Ids of the created custom roles. |
| <a name="output_name"></a> [name](#output\_name) | Project name. |
| <a name="output_number"></a> [number](#output\_number) | Project number. |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | Project id. |
| <a name="output_service_accounts"></a> [service\_accounts](#output\_service\_accounts) | Product robot service accounts in project. |
| <a name="output_sink_writer_identities"></a> [sink\_writer\_identities](#output\_sink\_writer\_identities) | Writer identities created for each sink. |

## Resource types
| Type | Used |
|------|-------|
| [google-beta_google_compute_shared_vpc_host_project](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_shared_vpc_host_project) | 1 |
| [google-beta_google_compute_shared_vpc_service_project](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_shared_vpc_service_project) | 2 |
| [google-beta_google_essential_contacts_contact](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_essential_contacts_contact) | 1 |
| [google-beta_google_monitoring_monitored_project](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_monitoring_monitored_project) | 1 |
| [google-beta_google_project_service_identity](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_project_service_identity) | 2 |
| [google_access_context_manager_service_perimeter_resource](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/access_context_manager_service_perimeter_resource) | 2 |
| [google_bigquery_dataset_iam_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset_iam_member) | 1 |
| [google_compute_project_metadata_item](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_project_metadata_item) | 1 |
| [google_kms_crypto_key_iam_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key_iam_member) | 1 |
| [google_logging_project_exclusion](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_project_exclusion) | 1 |
| [google_logging_project_sink](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_project_sink) | 1 |
| [google_org_policy_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/org_policy_policy) | 1 |
| [google_project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project) | 1 |
| [google_project_default_service_accounts](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_default_service_accounts) | 1 |
| [google_project_iam_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_binding) | 1 |
| [google_project_iam_custom_role](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role) | 1 |
| [google_project_iam_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | 8 |
| [google_project_service](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | 1 |
| [google_pubsub_topic_iam_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam_member) | 1 |
| [google_resource_manager_lien](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/resource_manager_lien) | 1 |
| [google_storage_bucket_iam_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | 1 |
| [google_tags_tag_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/tags_tag_binding) | 1 |
**`Used` only includes resource blocks.** `for_each` and `count` meta arguments, as well as resource blocks of modules are not considered.

## Modules

No modules.

## Resources by Files
### iam.tf
| Name | Type |
|------|------|
| [google_project_iam_binding.authoritative](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_binding) | resource |
| [google_project_iam_custom_role.roles](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role) | resource |
| [google_project_iam_member.additive](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.oslogin_admins](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.oslogin_compute_viewer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.oslogin_iam_serviceaccountuser](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.oslogin_users](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
### logging.tf
| Name | Type |
|------|------|
| [google_bigquery_dataset_iam_member.bq-sinks-binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset_iam_member) | resource |
| [google_logging_project_exclusion.logging-exclusion](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_project_exclusion) | resource |
| [google_logging_project_sink.sink](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_project_sink) | resource |
| [google_project_iam_member.bucket-sinks-binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_pubsub_topic_iam_member.pubsub-sinks-binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam_member) | resource |
| [google_storage_bucket_iam_member.gcs-sinks-binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
### main.tf
| Name | Type |
|------|------|
| [google-beta_google_essential_contacts_contact.contact](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_essential_contacts_contact) | resource |
| [google-beta_google_monitoring_monitored_project.primary](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_monitoring_monitored_project) | resource |
| [google_compute_project_metadata_item.oslogin_meta](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_project_metadata_item) | resource |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project) | resource |
| [google_project_service.project_services](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_resource_manager_lien.lien](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/resource_manager_lien) | resource |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |
### organization-policies.tf
| Name | Type |
|------|------|
| [google_org_policy_policy.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/org_policy_policy) | resource |
### service-accounts.tf
| Name | Type |
|------|------|
| [google-beta_google_project_service_identity.jit_si](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_project_service_identity) | resource |
| [google-beta_google_project_service_identity.servicenetworking](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_project_service_identity) | resource |
| [google_kms_crypto_key_iam_member.service_identity_cmek](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key_iam_member) | resource |
| [google_project_default_service_accounts.default_service_accounts](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_default_service_accounts) | resource |
| [google_project_iam_member.servicenetworking](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_bigquery_default_service_account.bq_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/bigquery_default_service_account) | data source |
| [google_storage_project_service_account.gcs_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/storage_project_service_account) | data source |
### shared-vpc.tf
| Name | Type |
|------|------|
| [google-beta_google_compute_shared_vpc_host_project.shared_vpc_host](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_shared_vpc_host_project) | resource |
| [google-beta_google_compute_shared_vpc_service_project.service_projects](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_shared_vpc_service_project) | resource |
| [google-beta_google_compute_shared_vpc_service_project.shared_vpc_service](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_shared_vpc_service_project) | resource |
| [google_project_iam_member.shared_vpc_host_robots](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
### tags.tf
| Name | Type |
|------|------|
| [google_tags_tag_binding.binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/tags_tag_binding) | resource |
### vpc-sc.tf
| Name | Type |
|------|------|
| [google_access_context_manager_service_perimeter_resource.bridge](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/access_context_manager_service_perimeter_resource) | resource |
| [google_access_context_manager_service_perimeter_resource.standard](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/access_context_manager_service_perimeter_resource) | resource |
<!-- END_TF_DOCS -->