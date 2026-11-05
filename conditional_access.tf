# Optional: a Conditional Access policy in report-only mode.
#
# Off by default because Conditional Access needs Entra ID P1 (or a trial),
# and the identity running Terraform needs the
# Policy.ReadWrite.ConditionalAccess permission (Conditional Access
# Administrator or Security Administrator for a user).
#
# Report-only means sign-ins are evaluated and logged, but nobody is blocked
# or prompted. You can check the results under Entra admin center > Sign-in
# logs > Report-only, then decide whether to turn it on. That is how a new CA
# policy should normally be rolled out.

module "group_ca_pilot" {
  source = "./modules/entra-group-rbac"
  count  = var.enable_conditional_access ? 1 : 0

  display_name = "sg-${local.name_base}-ca-mfa-pilot"
  description  = "Users in scope of the report-only lab MFA Conditional Access policy."
  owners       = local.group_owners
}

resource "azuread_conditional_access_policy" "require_mfa_pilot" {
  count = var.enable_conditional_access ? 1 : 0

  display_name = "LAB - Require MFA for pilot group (report-only)"
  state        = "enabledForReportingButNotEnforced"

  conditions {
    client_app_types = ["all"]

    applications {
      included_applications = ["All"]
    }

    users {
      included_groups = [module.group_ca_pilot[0].object_id]
    }
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["mfa"]
  }
}
