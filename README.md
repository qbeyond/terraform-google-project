<!-- BEGIN TFDOC -->

## Files

| name | description | resources |
|---|---|---|
| [iam.tf](./iam.tf) | Generic and OSLogin-specific IAM bindings and roles. | <code>google_project_iam_binding</code> · <code>google_project_iam_custom_role</code> · <code>google_project_iam_member</code> |
| [logging.tf](./logging.tf) | Log sinks and supporting resources. | <code>google_bigquery_dataset_iam_member</code> · <code>google_logging_project_exclusion</code> · <code>google_logging_project_sink</code> · <code>google_project_iam_member</code> · <code>google_pubsub_topic_iam_member</code> · <code>google_storage_bucket_iam_member</code> |
| [main.tf](./main.tf) | Module-level locals and resources. | <code>google_compute_project_metadata_item</code> · <code>google_essential_contacts_contact</code> · <code>google_monitoring_monitored_project</code> · <code>google_project</code> · <code>google_project_service</code> · <code>google_resource_manager_lien</code> |
| [organization-policies.tf](./organization-policies.tf) | Project-level organization policies. | <code>google_org_policy_policy</code> |
| [outputs.tf](./outputs.tf) | Module outputs. |  |
| [service-accounts.tf](./service-accounts.tf) | Service identities and supporting resources. | <code>google_kms_crypto_key_iam_member</code> · <code>google_project_default_service_accounts</code> · <code>google_project_iam_member</code> · <code>google_project_service_identity</code> |
| [shared-vpc.tf](./shared-vpc.tf) | Shared VPC project-level configuration. | <code>google_compute_shared_vpc_host_project</code> · <code>google_compute_shared_vpc_service_project</code> · <code>google_project_iam_member</code> |
| [tags.tf](./tags.tf) | None | <code>google_tags_tag_binding</code> |
| [variables.tf](./variables.tf) | Module variables. |  |
| [versions.tf](./versions.tf) | Version pins. |  |
| [vpc-sc.tf](./vpc-sc.tf) | VPC-SC project-level perimeter configuration. | <code>google_access_context_manager_service_perimeter_resource</code> |

## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [name](variables.tf#L140) | Project name and id suffix. | <code>string</code> | ✓ |  |
| [auto_create_network](variables.tf#L17) | Whether to create the default network for the project. | <code>bool</code> |  | <code>false</code> |
| [billing_account](variables.tf#L23) | Billing account id. | <code>string</code> |  | <code>null</code> |
| [contacts](variables.tf#L29) | List of essential contacts for this resource. Must be in the form EMAIL -> [NOTIFICATION_TYPES]. Valid notification types are ALL, SUSPENSION, SECURITY, TECHNICAL, BILLING, LEGAL, PRODUCT_UPDATES. | <code>map&#40;list&#40;string&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [custom_roles](variables.tf#L36) | Map of role name => list of permissions to create in this project. | <code>map&#40;list&#40;string&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [default_service_account](variables.tf#L43) | Project default service account setting: can be one of `delete`, `deprivilege`, `disable`, or `keep`. | <code>string</code> |  | <code>&#34;keep&#34;</code> |
| [descriptive_name](variables.tf#L49) | Name of the project name. Used for project name instead of `name` variable. | <code>string</code> |  | <code>null</code> |
| [group_iam](variables.tf#L55) | Authoritative IAM binding for organization groups, in {GROUP_EMAIL => [ROLES]} format. Group emails need to be static. Can be used in combination with the `iam` variable. | <code>map&#40;list&#40;string&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [iam](variables.tf#L62) | IAM bindings in {ROLE => [MEMBERS]} format. | <code>map&#40;list&#40;string&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [iam_additive](variables.tf#L69) | IAM additive bindings in {ROLE => [MEMBERS]} format. | <code>map&#40;list&#40;string&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [iam_additive_members](variables.tf#L76) | IAM additive bindings in {MEMBERS => [ROLE]} format. This might break if members are dynamic values. | <code>map&#40;list&#40;string&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [labels](variables.tf#L82) | Resource labels. | <code>map&#40;string&#41;</code> |  | <code>&#123;&#125;</code> |
| [lien_reason](variables.tf#L89) | If non-empty, creates a project lien with this description. | <code>string</code> |  | <code>&#34;&#34;</code> |
| [logging_exclusions](variables.tf#L95) | Logging exclusions for this project in the form {NAME -> FILTER}. | <code>map&#40;string&#41;</code> |  | <code>&#123;&#125;</code> |
| [logging_sinks](variables.tf#L102) | Logging sinks to create for this project. | <code title="map&#40;object&#40;&#123;&#10;  bq_partitioned_table &#61; optional&#40;bool&#41;&#10;  description          &#61; optional&#40;string&#41;&#10;  destination          &#61; string&#10;  disabled             &#61; optional&#40;bool, false&#41;&#10;  exclusions           &#61; optional&#40;map&#40;string&#41;, &#123;&#125;&#41;&#10;  filter               &#61; string&#10;  iam                  &#61; optional&#40;bool, true&#41;&#10;  type                 &#61; string&#10;  unique_writer        &#61; optional&#40;bool&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [metric_scopes](variables.tf#L133) | List of projects that will act as metric scopes for this project. | <code>list&#40;string&#41;</code> |  | <code>&#91;&#93;</code> |
| [org_policies](variables.tf#L145) | Organization policies applied to this project keyed by policy name. | <code title="map&#40;object&#40;&#123;&#10;  inherit_from_parent &#61; optional&#40;bool&#41; &#35; for list policies only.&#10;  reset               &#61; optional&#40;bool&#41;&#10;  allow &#61; optional&#40;object&#40;&#123;&#10;    all    &#61; optional&#40;bool&#41;&#10;    values &#61; optional&#40;list&#40;string&#41;&#41;&#10;  &#125;&#41;&#41;&#10;  deny &#61; optional&#40;object&#40;&#123;&#10;    all    &#61; optional&#40;bool&#41;&#10;    values &#61; optional&#40;list&#40;string&#41;&#41;&#10;  &#125;&#41;&#41;&#10;  enforce &#61; optional&#40;bool, true&#41; &#35; for boolean policies only.&#10;  rules &#61; optional&#40;list&#40;object&#40;&#123;&#10;    allow &#61; optional&#40;object&#40;&#123;&#10;      all    &#61; optional&#40;bool&#41;&#10;      values &#61; optional&#40;list&#40;string&#41;&#41;&#10;    &#125;&#41;&#41;&#10;    deny &#61; optional&#40;object&#40;&#123;&#10;      all    &#61; optional&#40;bool&#41;&#10;      values &#61; optional&#40;list&#40;string&#41;&#41;&#10;    &#125;&#41;&#41;&#10;    enforce &#61; optional&#40;bool, true&#41; &#35; for boolean policies only.&#10;    condition &#61; object&#40;&#123;&#10;      description &#61; optional&#40;string&#41;&#10;      expression  &#61; optional&#40;string&#41;&#10;      location    &#61; optional&#40;string&#41;&#10;      title       &#61; optional&#40;string&#41;&#10;    &#125;&#41;&#10;  &#125;&#41;&#41;, &#91;&#93;&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [org_policies_data_path](variables.tf#L185) | Path containing org policies in YAML format. | <code>string</code> |  | <code>null</code> |
| [oslogin](variables.tf#L191) | Enable OS Login. | <code>bool</code> |  | <code>false</code> |
| [oslogin_admins](variables.tf#L197) | List of IAM-style identities that will be granted roles necessary for OS Login administrators. | <code>list&#40;string&#41;</code> |  | <code>&#91;&#93;</code> |
| [oslogin_users](variables.tf#L205) | List of IAM-style identities that will be granted roles necessary for OS Login users. | <code>list&#40;string&#41;</code> |  | <code>&#91;&#93;</code> |
| [parent](variables.tf#L212) | Parent folder or organization in 'folders/folder_id' or 'organizations/org_id' format. | <code>string</code> |  | <code>null</code> |
| [prefix](variables.tf#L222) | Optional prefix used to generate project id and name. | <code>string</code> |  | <code>null</code> |
| [project_create](variables.tf#L232) | Create project. When set to false, uses a data source to reference existing project. | <code>bool</code> |  | <code>true</code> |
| [service_config](variables.tf#L238) | Configure service API activation. | <code title="object&#40;&#123;&#10;  disable_on_destroy         &#61; bool&#10;  disable_dependent_services &#61; bool&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code title="&#123;&#10;  disable_on_destroy         &#61; false&#10;  disable_dependent_services &#61; false&#10;&#125;">&#123;&#8230;&#125;</code> |
| [service_encryption_key_ids](variables.tf#L250) | Cloud KMS encryption key in {SERVICE => [KEY_URL]} format. | <code>map&#40;list&#40;string&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [service_perimeter_bridges](variables.tf#L257) | Name of VPC-SC Bridge perimeters to add project into. See comment in the variables file for format. | <code>list&#40;string&#41;</code> |  | <code>null</code> |
| [service_perimeter_standard](variables.tf#L264) | Name of VPC-SC Standard perimeter to add project into. See comment in the variables file for format. | <code>string</code> |  | <code>null</code> |
| [services](variables.tf#L270) | Service APIs to enable. | <code>list&#40;string&#41;</code> |  | <code>&#91;&#93;</code> |
| [shared_vpc_host_config](variables.tf#L276) | Configures this project as a Shared VPC host project (mutually exclusive with shared_vpc_service_project). | <code title="object&#40;&#123;&#10;  enabled          &#61; bool&#10;  service_projects &#61; optional&#40;list&#40;string&#41;, &#91;&#93;&#41;&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code>null</code> |
| [shared_vpc_service_config](variables.tf#L285) | Configures this project as a Shared VPC service project (mutually exclusive with shared_vpc_host_config). | <code title="object&#40;&#123;&#10;  host_project         &#61; string&#10;  service_identity_iam &#61; optional&#40;map&#40;list&#40;string&#41;&#41;&#41;&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code>null</code> |
| [skip_delete](variables.tf#L295) | Allows the underlying resources to be destroyed without destroying the project itself. | <code>bool</code> |  | <code>false</code> |
| [tag_bindings](variables.tf#L301) | Tag bindings for this project, in key => tag value id format. | <code>map&#40;string&#41;</code> |  | <code>null</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [custom_roles](outputs.tf#L17) | Ids of the created custom roles. |  |
| [name](outputs.tf#L25) | Project name. |  |
| [number](outputs.tf#L37) | Project number. |  |
| [project_id](outputs.tf#L54) | Project id. |  |
| [service_accounts](outputs.tf#L73) | Product robot service accounts in project. |  |
| [sink_writer_identities](outputs.tf#L89) | Writer identities created for each sink. |  |

<!-- END TFDOC -->

<!-- BEGIN_TF_DOCS -->
## Usage

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

This Module creates a GCP Project with automating Cloud Encrypter/Decrypter Role with KMS
It is possible to include yaml config files.
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

This Module creates a GCP Project with a IAM
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

This Module creates a GCP Project with org policies
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

This Module creates a GCP Project as a shared vpc host
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

This Module creates a GCP Project with tags
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