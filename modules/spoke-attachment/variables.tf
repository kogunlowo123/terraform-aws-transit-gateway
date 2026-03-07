################################################################################
# Required Variables
################################################################################

variable "name" {
  description = "Name tag for the VPC attachment."
  type        = string
}

variable "transit_gateway_id" {
  description = "ID of the Transit Gateway to attach the VPC to."
  type        = string
}

variable "vpc_id" {
  description = "ID of the spoke VPC to attach."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs in the spoke VPC. Use one subnet per AZ for high availability."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "At least one subnet ID must be provided."
  }
}

################################################################################
# Optional Variables
################################################################################

variable "appliance_mode_support" {
  description = "Whether appliance mode is enabled. Enable for stateful appliances like firewalls to ensure symmetric routing."
  type        = bool
  default     = false
}

variable "dns_support" {
  description = "Whether DNS support is enabled for this attachment."
  type        = bool
  default     = true
}

variable "transit_gateway_default_route_table_association" {
  description = "Whether this attachment is associated with the Transit Gateway default route table."
  type        = bool
  default     = true
}

variable "transit_gateway_default_route_table_propagation" {
  description = "Whether this attachment propagates routes to the Transit Gateway default route table."
  type        = bool
  default     = true
}

variable "route_table_id" {
  description = "ID of a custom Transit Gateway route table to associate this attachment with. Set to null to skip."
  type        = string
  default     = null
}

variable "propagation_route_table_ids" {
  description = "List of Transit Gateway route table IDs to propagate routes into."
  type        = list(string)
  default     = []
}

variable "vpc_route_table_ids" {
  description = "List of VPC route table IDs to add routes pointing to the Transit Gateway. Set to null to skip."
  type        = list(string)
  default     = null
}

variable "destination_cidrs" {
  description = "List of destination CIDR blocks for VPC routes pointing to the Transit Gateway."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to the VPC attachment."
  type        = map(string)
  default     = {}
}
