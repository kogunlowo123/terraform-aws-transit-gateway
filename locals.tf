################################################################################
# Local Values
################################################################################

locals {
  # Common tags applied to all resources
  common_tags = merge(
    var.tags,
    {
      "terraform-module" = "terraform-aws-transit-gateway"
      "managed-by"       = "terraform"
    }
  )

  # Determine if RAM sharing is needed
  enable_ram_sharing = length(var.ram_principals) > 0

  # Flatten routes for iteration
  routes_with_index = {
    for idx, route in var.routes :
    "${route.route_table_key}-${route.destination_cidr}" => route
  }
}
