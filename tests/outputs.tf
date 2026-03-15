output "transit_gateway_id" {
  description = "The ID of the Transit Gateway"
  value       = module.transit_gateway.transit_gateway_id
}

output "transit_gateway_arn" {
  description = "The ARN of the Transit Gateway"
  value       = module.transit_gateway.transit_gateway_arn
}

output "route_table_ids" {
  description = "Map of custom route table IDs"
  value       = module.transit_gateway.route_table_ids
}
