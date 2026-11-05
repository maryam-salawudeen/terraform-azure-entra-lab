# tflint settings. The bundled Terraform ruleset catches unused variables,
# missing descriptions, missing version pins and naming problems.
config {
  call_module_type = "local"
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}
