locals {
  # automatically load environment variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))

  # automatically load region variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # automatically load platform variables
  platform_vars = read_terragrunt_config(find_in_parent_folders("platform.hcl"))
}

# merge common, environment, and region variables
inputs = merge(
  local.environment_vars.locals,
  local.region_vars.locals,
  local.platform_vars.locals
)
