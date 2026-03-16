variable "name" {
  description = "Name to assign to the Transit Gateway and associated resources."
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
  description = "Private ASN for the Amazon side of a BGP session (64512-65534 or 4200000000-4294967294)."
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
  description = "Whether resource attachment requests are automatically accepted."
  type        = bool
  default     = false
}

variable "enable_default_route_table_association" {
  description = "Whether attachments are automatically associated with the default route table."
  type        = bool
  default     = true
}

variable "enable_default_route_table_propagation" {
  description = "Whether attachments automatically propagate routes to the default route table."
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Whether DNS support is enabled on the Transit Gateway."
  type        = bool
  default     = true
}

variable "enable_vpn_ecmp_support" {
  description = "Whether ECMP support is enabled for VPN connections."
  type        = bool
  default     = true
}

variable "enable_multicast_support" {
  description = "Whether multicast is enabled on the Transit Gateway."
  type        = bool
  default     = false
}

variable "vpc_attachments" {
  description = "Map of VPC attachment configurations."
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

variable "route_tables" {
  description = "Map of custom Transit Gateway route tables."
  type = map(object({
    name = string
  }))
  default = {}
}

variable "routes" {
  description = "List of static routes to add to Transit Gateway route tables."
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

variable "route_table_associations" {
  description = "Map of route table associations linking attachments to route tables."
  type = map(object({
    route_table_key = string
    attachment_key  = string
  }))
  default = {}
}

variable "route_table_propagations" {
  description = "Map of route table propagations for dynamic route advertisement."
  type = map(object({
    route_table_key = string
    attachment_key  = string
  }))
  default = {}
}

variable "ram_principals" {
  description = "List of AWS account IDs or Organization ARNs to share the Transit Gateway with."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}
