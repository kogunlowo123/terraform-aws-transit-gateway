################################################################################
# Transit Gateway Variables
################################################################################

variable "name" {
  description = "Name to assign to the Transit Gateway and associated resources. Used as a prefix for resource naming."
  type        = string

  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 128
    error_message = "Name must be between 1 and 128 characters."
  }
}

variable "description" {
  description = "Description of the Transit Gateway."
  type        = string
  default     = ""
}

variable "amazon_side_asn" {
  description = "Private Autonomous System Number (ASN) for the Amazon side of a BGP session. Must be in the 64512-65534 or 4200000000-4294967294 range."
  type        = number
  default     = 64512

  validation {
    condition = (
      (var.amazon_side_asn >= 64512 && var.amazon_side_asn <= 65534) ||
      (var.amazon_side_asn >= 4200000000 && var.amazon_side_asn <= 4294967294)
    )
    error_message = "Amazon side ASN must be in the range 64512-65534 or 4200000000-4294967294."
  }
}

variable "enable_auto_accept_shared_attachments" {
  description = "Whether resource attachment requests are automatically accepted. When enabled, cross-account VPC attachments are accepted without manual approval."
  type        = bool
  default     = false
}

variable "enable_default_route_table_association" {
  description = "Whether resource attachments are automatically associated with the default route table. Disable when using custom route tables for network segmentation."
  type        = bool
  default     = true
}

variable "enable_default_route_table_propagation" {
  description = "Whether resource attachments automatically propagate routes to the default route table. Disable for granular route control."
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Whether DNS support is enabled on the Transit Gateway. Required for DNS resolution across attached VPCs."
  type        = bool
  default     = true
}

variable "enable_vpn_ecmp_support" {
  description = "Whether Equal Cost Multipath Protocol (ECMP) support is enabled for VPN connections. Enables load balancing across multiple VPN tunnels."
  type        = bool
  default     = true
}

variable "enable_multicast_support" {
  description = "Whether multicast is enabled on the Transit Gateway. Once enabled, cannot be disabled without recreating the Transit Gateway."
  type        = bool
  default     = false
}

################################################################################
# VPC Attachment Variables
################################################################################

variable "vpc_attachments" {
  description = <<-EOT
    Map of VPC attachment configurations. Each entry creates a VPC attachment to the Transit Gateway.

    Key: Unique identifier for the attachment (used for resource references).
    Values:
      - vpc_id: ID of the VPC to attach.
      - subnet_ids: List of subnet IDs in different AZs for high availability.
      - appliance_mode_support: Enable for stateful network appliances (e.g., firewalls).
      - dns_support: Enable DNS resolution for the attachment.
      - transit_gateway_default_route_table_association: Override default route table association for this attachment.
      - transit_gateway_default_route_table_propagation: Override default route table propagation for this attachment.
      - tags: Additional tags specific to this attachment.
  EOT
  type = map(object({
    vpc_id                                          = string
    subnet_ids                                      = list(string)
    appliance_mode_support                          = optional(bool, false)
    dns_support                                     = optional(bool, true)
    transit_gateway_default_route_table_association = optional(bool, true)
    transit_gateway_default_route_table_propagation = optional(bool, true)
    tags                                            = optional(map(string), {})
  }))
  default = {}
}

################################################################################
# Route Table Variables
################################################################################

variable "route_tables" {
  description = <<-EOT
    Map of custom Transit Gateway route tables. Use custom route tables for network segmentation
    and traffic isolation between VPC attachments.

    Key: Unique identifier for the route table.
    Values:
      - name: Display name for the route table.
  EOT
  type = map(object({
    name = string
  }))
  default = {}
}

variable "routes" {
  description = <<-EOT
    List of static routes to add to Transit Gateway route tables. Supports both forwarding routes
    and blackhole routes for traffic filtering.

    Values:
      - destination_cidr: Destination CIDR block for the route.
      - route_table_key: Key referencing an entry in the route_tables variable.
      - attachment_key: Key referencing an entry in vpc_attachments (ignored for blackhole routes).
      - blackhole: When true, traffic matching this route is dropped.
  EOT
  type = list(object({
    destination_cidr = string
    route_table_key  = string
    attachment_key   = optional(string, "")
    blackhole        = optional(bool, false)
  }))
  default = []

  validation {
    condition = alltrue([
      for route in var.routes :
      can(cidrhost(route.destination_cidr, 0))
    ])
    error_message = "All destination_cidr values must be valid CIDR blocks."
  }
}

################################################################################
# Route Table Association and Propagation Variables
################################################################################

variable "route_table_associations" {
  description = <<-EOT
    Map of route table associations. Associates VPC attachments with specific route tables
    for controlling which route table an attachment uses for outbound routing.

    Key: Unique identifier for the association.
    Values:
      - route_table_key: Key referencing an entry in route_tables.
      - attachment_key: Key referencing an entry in vpc_attachments.
  EOT
  type = map(object({
    route_table_key = string
    attachment_key  = string
  }))
  default = {}
}

variable "route_table_propagations" {
  description = <<-EOT
    Map of route table propagations. Propagates routes from VPC attachments into specified
    route tables, enabling dynamic route advertisement.

    Key: Unique identifier for the propagation.
    Values:
      - route_table_key: Key referencing an entry in route_tables.
      - attachment_key: Key referencing an entry in vpc_attachments.
  EOT
  type = map(object({
    route_table_key = string
    attachment_key  = string
  }))
  default = {}
}

################################################################################
# RAM (Resource Access Manager) Variables
################################################################################

variable "ram_principals" {
  description = <<-EOT
    List of AWS account IDs or AWS Organization ARNs to share the Transit Gateway with via
    AWS Resource Access Manager (RAM). Enables cross-account Transit Gateway usage.

    Examples:
      - AWS Account ID: "123456789012"
      - Organization ARN: "arn:aws:organizations::123456789012:organization/o-abc123"
      - OU ARN: "arn:aws:organizations::123456789012:ou/o-abc123/ou-ab12-abcd1234"
  EOT
  type    = list(string)
  default = []
}

################################################################################
# Tagging Variables
################################################################################

variable "tags" {
  description = "A map of tags to apply to all resources created by this module. Tags are key-value pairs used for resource identification, cost allocation, and access control."
  type        = map(string)
  default     = {}
}
