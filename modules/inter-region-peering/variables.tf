################################################################################
# Required Variables
################################################################################

variable "name" {
  description = "Name tag for the peering attachment."
  type        = string
}

variable "transit_gateway_id" {
  description = "ID of the local (requester) Transit Gateway."
  type        = string
}

variable "peer_transit_gateway_id" {
  description = "ID of the remote (peer) Transit Gateway."
  type        = string
}

################################################################################
# Optional Variables
################################################################################

variable "peer_account_id" {
  description = "AWS account ID of the peer Transit Gateway owner. Defaults to the current account of the peer provider."
  type        = string
  default     = null
}

variable "auto_accept" {
  description = "Whether to automatically accept the peering attachment on the peer side. Requires the peer provider to be configured."
  type        = bool
  default     = true
}

variable "requester_route_table_id" {
  description = "Route table ID on the requester side to associate with the peering attachment."
  type        = string
  default     = null
}

variable "accepter_route_table_id" {
  description = "Route table ID on the accepter side to associate with the peering attachment."
  type        = string
  default     = null
}

variable "requester_routes" {
  description = "List of destination CIDR blocks for static routes on the requester side pointing to the peering attachment."
  type        = list(string)
  default     = []
}

variable "accepter_routes" {
  description = "List of destination CIDR blocks for static routes on the accepter side pointing to the peering attachment."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all peering resources."
  type        = map(string)
  default     = {}
}
