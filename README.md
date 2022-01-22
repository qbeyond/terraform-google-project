# Project Module

## Examples

### Minimal example with IAM

```hcl
locals {
  gke_service_account = "my_gke_service_account"
}

module "project" {
  source          = "./modules/project"
  billing_account = "123456-123456-123456"
  name            = "project-example"
  parent          = "folders/1234567890"
  prefix          = "foo"
  services        = [
    "container.googleapis.com",
    "stackdriver.googleapis.com"
  ]
  iam = {
    "roles/container.hostServiceAgentUser" = [
      "serviceAccount:${local.gke_service_account}"
    ]
  }
}
# tftest:modules=1:resources=4
```

### Minimal example with IAM additive roles

```hcl
module "project" {
  source          = "./modules/project"
  name            = "project-example"

  iam_additive = {
    "roles/viewer"               = ["group:one@example.org", "group:two@xample.org"],
    "roles/storage.objectAdmin"  = ["group:two@example.org"],
    "roles/owner"                = ["group:three@example.org"],
  }
}
# tftest:modules=1:resources=5
```

### Organization policies

```hcl
module "project" {
  source          = "./modules/project"
  billing_account = "123456-123456-123456"
  name            = "project-example"
  parent          = "folders/1234567890"
  prefix          = "foo"
  services        = [
    "container.googleapis.com",
    "stackdriver.googleapis.com"
  ]
  policy_boolean = {
    "constraints/compute.disableGuestAttributesAccess" = true
    "constraints/compute.skipDefaultNetworkCreation" = true
  }
  policy_list = {
    "constraints/compute.trustedImageProjects" = {
      inherit_from_parent = null
      suggested_value = null
      status = true
      values = ["projects/my-project"]
    }
  }
}
# tftest:modules=1:resources=6
```

## Logging Sinks
```hcl
module "gcs" {
  source        = "./modules/gcs"
  project_id    = var.project_id
  name          = "gcs_sink"
  force_destroy = true
}

module "dataset" {
  source     = "./modules/bigquery-dataset"
  project_id = var.project_id
  id         = "bq_sink"
}

module "pubsub" {
  source     = "./modules/pubsub"
  project_id = var.project_id
  name       = "pubsub_sink"
}

module "bucket" {
  source      = "./modules/logging-bucket"
  parent_type = "project"
  parent      = "my-project"
  id          = "bucket"
}

module "project-host" {
  source          = "./modules/project"
  name            = "my-project"
  billing_account = "123456-123456-123456"
  parent          = "folders/1234567890"
  logging_sinks = {
    warnings = {
      type          = "gcs"
      destination   = module.gcs.name
      filter        = "severity=WARNING"
      iam           = false
      unique_writer = false
      exclusions    = {}
    }
    info = {
      type          = "bigquery"
      destination   = module.dataset.id
      filter        = "severity=INFO"
      iam           = false
      unique_writer = false
      exclusions    = {}
    }
    notice = {
      type          = "pubsub"
      destination   = module.pubsub.id
      filter        = "severity=NOTICE"
      iam           = true
      unique_writer = false
      exclusions    = {}
    }
    debug = {
      type          = "logging"
      destination   = module.bucket.id
      filter        = "severity=DEBUG"
      iam           = true
      unique_writer = false
      exclusions = {
        no-compute = "logName:compute"
      }
    }
  }
  logging_exclusions = {
    no-gce-instances = "resource.type=gce_instance"
  }
}
# tftest:modules=5:resources=12
```

## Cloud KMS encryption keys

```hcl
module "project" {
  source          = "./modules/project"
  name            = "my-project"
  billing_account = "123456-123456-123456"
  prefix          = "foo"
  services = [
    "compute.googleapis.com",
    "storage.googleapis.com"
  ]
  service_encryption_key_ids = {
    compute = [
      "projects/kms-central-prj/locations/europe-west3/keyRings/my-keyring/cryptoKeys/europe3-gce",
      "projects/kms-central-prj/locations/europe-west4/keyRings/my-keyring/cryptoKeys/europe4-gce"
    ]
    storage = [
      "projects/kms-central-prj/locations/europe/keyRings/my-keyring/cryptoKeys/europe-gcs"
    ]
  }
}
# tftest:modules=1:resources=7
```

<!-- TFDOC OPTS files:1 -->
<!-- BEGIN TFDOC -->

## Files

| name | description | resources |
|---|---|---|
| [iam.tf](./iam.tf) | Generic and OSLogin-specific IAM bindings and roles. | <code>google_project_iam_binding</code> · <code>google_project_iam_custom_role</code> · <code>google_project_iam_member</code> |
| [logging.tf](./logging.tf) | Log sinks and supporting resources. | <code>google_bigquery_dataset_iam_member</code> · <code>google_logging_project_exclusion</code> · <code>google_logging_project_sink</code> · <code>google_project_iam_member</code> · <code>google_pubsub_topic_iam_member</code> · <code>google_storage_bucket_iam_member</code> |
| [main.tf](./main.tf) | Module-level locals and resources. | <code>google_compute_project_metadata_item</code> · <code>google_essential_contacts_contact</code> · <code>google_monitoring_monitored_project</code> · <code>google_project</code> · <code>google_project_service</code> · <code>google_resource_manager_lien</code> |
| [organization-policies.tf](./organization-policies.tf) | Project-level organization policies. | <code>google_project_organization_policy</code> |
| [outputs.tf](./outputs.tf) | Module outputs. |  |
| [service_accounts.tf](./service_accounts.tf) | Service identities and supporting resources. | <code>google_kms_crypto_key_iam_member</code> · <code>google_project_service_identity</code> |
| [shared_vpc.tf](./shared_vpc.tf) | Shared VPC project-level configuration. | <code>google_compute_shared_vpc_host_project</code> · <code>google_compute_shared_vpc_service_project</code> |
| [variables.tf](./variables.tf) | Module variables. |  |
| [versions.tf](./versions.tf) | Version pins. |  |
| [vpc-sc.tf](./vpc-sc.tf) | VPC-SC project-level perimeter configuration. | <code>google_access_context_manager_service_perimeter_resource</code> |

## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [name](variables.tf#L109) | Project name and id suffix. | <code>string</code> | ✓ |  |
| [auto_create_network](variables.tf#L17) | Whether to create the default network for the project | <code>bool</code> |  | <code>false</code> |
| [billing_account](variables.tf#L23) | Billing account id. | <code>string</code> |  | <code>null</code> |
| [contacts](variables.tf#L29) | List of essential contacts for this resource. Must be in the form EMAIL -> [NOTIFICATION_TYPES]. Valid notification types are ALL, SUSPENSION, SECURITY, TECHNICAL, BILLING, LEGAL, PRODUCT_UPDATES | <code>map&#40;list&#40;string&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [custom_roles](variables.tf#L35) | Map of role name => list of permissions to create in this project. | <code>map&#40;list&#40;string&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [descriptive_name](variables.tf#L41) | Name of the project name. Used for project name instead of `name` variable | <code>string</code> |  | <code>null</code> |
| [group_iam](variables.tf#L47) | Authoritative IAM binding for organization groups, in {GROUP_EMAIL => [ROLES]} format. Group emails need to be static. Can be used in combination with the `iam` variable. | <code>map&#40;list&#40;string&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [iam](variables.tf#L53) | IAM bindings in {ROLE => [MEMBERS]} format. | <code>map&#40;list&#40;string&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [iam_additive](variables.tf#L59) | IAM additive bindings in {ROLE => [MEMBERS]} format. | <code>map&#40;list&#40;string&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [iam_additive_members](variables.tf#L65) | IAM additive bindings in {MEMBERS => [ROLE]} format. This might break if members are dynamic values. | <code>map&#40;list&#40;string&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [labels](variables.tf#L71) | Resource labels. | <code>map&#40;string&#41;</code> |  | <code>&#123;&#125;</code> |
| [lien_reason](variables.tf#L77) | If non-empty, creates a project lien with this description. | <code>string</code> |  | <code>&#34;&#34;</code> |
| [logging_exclusions](variables.tf#L83) | Logging exclusions for this project in the form {NAME -> FILTER}. | <code>map&#40;string&#41;</code> |  | <code>&#123;&#125;</code> |
| [logging_sinks](variables.tf#L89) | Logging sinks to create for this project. | <code title="map&#40;object&#40;&#123;&#10;  destination   &#61; string&#10;  type          &#61; string&#10;  filter        &#61; string&#10;  iam           &#61; bool&#10;  unique_writer &#61; bool&#10;  exclusions &#61; map&#40;string&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [metric_scopes](variables.tf#L103) | List of projects that will act as metric scopes for this project. | <code>list&#40;string&#41;</code> |  | <code>null</code> |
| [oslogin](variables.tf#L114) | Enable OS Login. | <code>bool</code> |  | <code>false</code> |
| [oslogin_admins](variables.tf#L120) | List of IAM-style identities that will be granted roles necessary for OS Login administrators. | <code>list&#40;string&#41;</code> |  | <code>&#91;&#93;</code> |
| [oslogin_users](variables.tf#L126) | List of IAM-style identities that will be granted roles necessary for OS Login users. | <code>list&#40;string&#41;</code> |  | <code>&#91;&#93;</code> |
| [parent](variables.tf#L132) | Parent folder or organization in 'folders/folder_id' or 'organizations/org_id' format. | <code>string</code> |  | <code>null</code> |
| [policy_boolean](variables.tf#L142) | Map of boolean org policies and enforcement value, set value to null for policy restore. | <code>map&#40;bool&#41;</code> |  | <code>&#123;&#125;</code> |
| [policy_list](variables.tf#L148) | Map of list org policies, status is true for allow, false for deny, null for restore. Values can only be used for allow or deny. | <code title="map&#40;object&#40;&#123;&#10;  inherit_from_parent &#61; bool&#10;  suggested_value     &#61; string&#10;  status              &#61; bool&#10;  values              &#61; list&#40;string&#41;&#10;&#125;&#41;&#41;">map&#40;object&#40;&#123;&#8230;&#125;&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [prefix](variables.tf#L159) | Prefix used to generate project id and name. | <code>string</code> |  | <code>null</code> |
| [project_create](variables.tf#L165) | Create project. When set to false, uses a data source to reference existing project. | <code>bool</code> |  | <code>true</code> |
| [service_config](variables.tf#L171) | Configure service API activation. | <code title="object&#40;&#123;&#10;  disable_on_destroy         &#61; bool&#10;  disable_dependent_services &#61; bool&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code title="&#123;&#10;  disable_on_destroy         &#61; true&#10;  disable_dependent_services &#61; true&#10;&#125;">&#123;&#8230;&#125;</code> |
| [service_encryption_key_ids](variables.tf#L183) | Cloud KMS encryption key in {SERVICE => [KEY_URL]} format. | <code>map&#40;list&#40;string&#41;&#41;</code> |  | <code>&#123;&#125;</code> |
| [service_perimeter_bridges](variables.tf#L190) | Name of VPC-SC Bridge perimeters to add project into. See comment in the variables file for format. | <code>list&#40;string&#41;</code> |  | <code>null</code> |
| [service_perimeter_standard](variables.tf#L197) | Name of VPC-SC Standard perimeter to add project into. See comment in the variables file for format. | <code>string</code> |  | <code>null</code> |
| [services](variables.tf#L203) | Service APIs to enable. | <code>list&#40;string&#41;</code> |  | <code>&#91;&#93;</code> |
| [shared_vpc_host_config](variables.tf#L209) | Configures this project as a Shared VPC host project (mutually exclusive with shared_vpc_service_project). | <code title="object&#40;&#123;&#10;  enabled          &#61; bool&#10;  service_projects &#61; list&#40;string&#41;&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code title="&#123;&#10;  enabled          &#61; false&#10;  service_projects &#61; &#91;&#93;&#10;&#125;">&#123;&#8230;&#125;</code> |
| [shared_vpc_service_config](variables.tf#L221) | Configures this project as a Shared VPC service project (mutually exclusive with shared_vpc_host_config). | <code title="object&#40;&#123;&#10;  attach       &#61; bool&#10;  host_project &#61; string&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code title="&#123;&#10;  attach       &#61; false&#10;  host_project &#61; &#34;&#34;&#10;&#125;">&#123;&#8230;&#125;</code> |
| [skip_delete](variables.tf#L233) | Allows the underlying resources to be destroyed without destroying the project itself. | <code>bool</code> |  | <code>false</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [custom_roles](outputs.tf#L17) | Ids of the created custom roles. |  |
| [name](outputs.tf#L25) | Project name. |  |
| [number](outputs.tf#L37) | Project number. |  |
| [project_id](outputs.tf#L49) | Project id. |  |
| [service_accounts](outputs.tf#L63) | Product robot service accounts in project. |  |
| [sink_writer_identities](outputs.tf#L79) | Writer identities created for each sink. |  |

<!-- END TFDOC -->
