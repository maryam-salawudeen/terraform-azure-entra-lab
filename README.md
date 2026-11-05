# terraform-azure-entra-lab

A personal lab where I manage a small Azure and Entra ID setup with Terraform. I built it to learn Terraform hands-on and to practise the way infrastructure changes are usually handled on a team: every change goes through a pull request, and CI checks the code before it is merged.

It is a lab, not a production deployment. It is small on purpose and costs close to nothing to run.

## What it builds

| Resource | What it shows |
| --- | --- |
| Resource group with standard tags | Consistent tagging (Owner, Environment, ManagedBy, Project) applied from one `locals` block |
| Storage account | Secure defaults: TLS 1.2 minimum, HTTPS only, no public blob access, no cross-tenant replication, infrastructure encryption, soft delete and versioning for blobs |
| Key Vault | Azure RBAC for data access instead of access policies, soft delete, optional purge protection |
| Three Entra ID security groups | Least privilege: each group gets the smallest built-in role it needs, scoped to the resource group, the storage account or the vault, never the subscription |
| Two Azure Policy assignments | Policy as code: "Allowed locations" and "Require a tag on resources", assigned to the resource group |
| Conditional Access policy (optional, off by default) | An MFA policy for a pilot group in report-only mode, the usual way to test a new CA policy before enforcing it |

The three groups and their roles:

| Group | Role | Scope |
| --- | --- | --- |
| `sg-<prefix>-lab-readers` | Reader | Resource group |
| `sg-<prefix>-lab-storage-operators` | Reader, Storage Blob Data Contributor | Resource group, storage account |
| `sg-<prefix>-lab-kv-secret-readers` | Key Vault Secrets User | Key Vault |

Access goes to groups and never directly to users, so adding or removing a person is a membership change that is easy to review in an access review. No group gets Owner, Contributor or User Access Administrator.

There are no VMs. Anything that needs a paid licence (Conditional Access needs Entra ID P1) is behind a variable that is off by default.

## Files

| File | Purpose |
| --- | --- |
| `versions.tf` | Terraform version and pinned provider versions (`azurerm` 4.x, `azuread` 3.x, `random` 3.x) |
| `.terraform.lock.hcl` | Exact provider versions and checksums, so every machine and CI run uses the same builds |
| `providers.tf` | Provider settings. Both providers log in with your Azure CLI session; no IDs or secrets are stored here |
| `backend.tf` | A commented example of remote state in an Azure storage account. Local state is the default |
| `variables.tf` | All inputs, with descriptions, defaults and validation |
| `terraform.tfvars.example` | Example values. Copy it to `terraform.tfvars` (which is gitignored) |
| `main.tf` | Random name suffix, shared tags, the resource group and the storage module call |
| `keyvault.tf` | The Key Vault |
| `identity.tf` | The Entra ID groups and their role assignments |
| `policy.tf` | The Azure Policy assignments |
| `conditional_access.tf` | The optional report-only Conditional Access policy and its pilot group |
| `outputs.tf` | Names, IDs and URIs printed after apply |
| `modules/secure-storage/` | Reusable module for a storage account with secure defaults |
| `modules/entra-group-rbac/` | Reusable module that creates a security group and assigns it Azure roles |
| `.tflint.hcl` | tflint settings (Terraform recommended rules) |
| `.github/workflows/terraform-ci.yml` | Pull request checks. Needs no Azure credentials |
| `.github/workflows/terraform-plan.yml` | Optional plan and apply with GitHub OIDC. Disabled until you turn it on |

## Running it against your own subscription

You need Terraform 1.9 or later, the Azure CLI, and an Azure subscription where you can create role assignments (Owner, or Contributor plus User Access Administrator). Your account also has to be allowed to create security groups in Entra ID, which is the default unless your tenant restricts it.

A free or pay-as-you-go subscription works. The storage account and Key Vault cost a few cents at most with no data in them, but check Cost Management if you leave the lab running.

1. Sign in and pick the subscription.

   ```bash
   az login
   az account set --subscription "<subscription name or id>"
   export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
   ```

2. Create your variables file and edit it.

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. Download the providers and set up the working folder.

   ```bash
   terraform init
   ```

4. See what Terraform would create. Read the plan before going further.

   ```bash
   terraform plan -out=tfplan
   ```

5. Create the resources from that saved plan.

   ```bash
   terraform apply tfplan
   ```

6. When you are done, remove everything.

   ```bash
   terraform destroy
   ```

   The Key Vault goes into a soft-deleted state for 7 days after destroy. With purge protection off you can purge it early with `az keyvault purge --name <vault name>`. The random suffix means a new apply will not clash with the old name either way.

To try the Conditional Access policy, set `enable_conditional_access = true`. Your tenant needs Entra ID P1 (a trial is fine) and you need the Conditional Access Administrator or Security Administrator role. The policy is created in report-only mode, so it never blocks or prompts anyone. Results show up in the Entra admin center under Sign-in logs, on the Report-only tab.

## Remote state

By default Terraform keeps state in a local `terraform.tfstate` file. That file is gitignored because it can contain sensitive values.

For a team, state belongs in shared storage with locking. `backend.tf` has a commented `azurerm` backend block that stores state in a blob container, signs in with Entra ID instead of a storage key, and locks state with a blob lease. Create the storage account, uncomment the block, fill in the names, then run `terraform init -migrate-state`.

## Pull request workflow and CI

`main` only changes through pull requests. On each PR, `terraform-ci.yml` runs:

- `terraform fmt -check` to catch formatting differences
- `terraform init -backend=false` and `terraform validate` to check syntax, types and references without touching Azure
- `tflint` with the Terraform recommended rules (unused variables, missing descriptions, missing version pins)
- `checkov`, a security scanner for infrastructure code

None of these steps need Azure credentials, so they pass on a public repo without secrets.

Checkov runs in soft-fail mode: it prints every finding but does not fail the build. Some findings are expected because of lab choices that a real environment would make differently:

- no private endpoints, and the Key Vault network rule defaults to Allow so it can be reached from a laptop
- locally redundant storage instead of geo-redundant
- Key Vault purge protection off, so the lab can be destroyed and rebuilt
- storage account key access left on by default (see `storage_shared_key_enabled`)

### Optional plan and apply with OIDC

`terraform-plan.yml` shows how plan and apply would run from GitHub Actions against a real subscription. It uses GitHub OIDC (workload identity federation), so no client secret is stored in GitHub. It only runs when started by hand and only if the repository variable `AZURE_PLAN_ENABLED` is `true`. The setup steps are in the comments at the top of the file. It needs a remote backend first, otherwise every CI plan starts from empty state.

## What I learned

_To fill in myself after working through the lab._

- What surprised me about Terraform compared with clicking through the portal:
- Something that broke, and how I worked out why:
- How I would change this for a real team or a production subscription:
- What I want to try next:
