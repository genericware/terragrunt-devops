locals {
  # load variables
  environment_vars  = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  region_vars       = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  platform_vars     = read_terragrunt_config(find_in_parent_folders("platform.hcl"))
  profile_vars      = read_terragrunt_config(find_in_parent_folders("profile.hcl"))
}

# merge variables
inputs = merge(
  local.environment_vars.locals,
  local.region_vars.locals,
  local.platform_vars.locals,
  local.profile_vars.locals
)
