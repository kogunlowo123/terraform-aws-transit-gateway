output "transit_gateway_id" {
  description = "The ID of the Transit Gateway."
  value       = aws_ec2_transit_gateway.this.id
}

output "transit_gateway_arn" {
  description = "The ARN of the Transit Gateway."
  value       = aws_ec2_transit_gateway.this.arn
}

output "transit_gateway_owner_id" {
  description = "The AWS account ID of the Transit Gateway owner."
  value       = aws_ec2_transit_gateway.this.owner_id
}

output "transit_gateway_association_default_route_table_id" {
  description = "The ID of the default association route table."
  value       = aws_ec2_transit_gateway.this.association_default_route_table_id
}

output "transit_gateway_propagation_default_route_table_id" {
  description = "The ID of the default propagation route table."
  value       = aws_ec2_transit_gateway.this.propagation_default_route_table_id
}

output "vpc_attachment_ids" {
  description = "Map of VPC attachment IDs keyed by the attachment name."
  value       = { for k, v in aws_ec2_transit_gateway_vpc_attachment.this : k => v.id }
}

output "vpc_attachment_details" {
  description = "Map of VPC attachment details including ID, VPC ID, and subnet IDs."
  value = {
    for k, v in aws_ec2_transit_gateway_vpc_attachment.this : k => {
      id         = v.id
      vpc_id     = v.vpc_id
      subnet_ids = v.subnet_ids
    }
  }
}

output "route_table_ids" {
  description = "Map of custom route table IDs keyed by the route table name."
  value       = { for k, v in aws_ec2_transit_gateway_route_table.this : k => v.id }
}

output "ram_resource_share_id" {
  description = "The ID of the RAM resource share."
  value       = length(var.ram_principals) > 0 ? aws_ram_resource_share.this[0].id : null
}

output "ram_resource_share_arn" {
  description = "The ARN of the RAM resource share."
  value       = length(var.ram_principals) > 0 ? aws_ram_resource_share.this[0].arn : null
}

output "aws_region" {
  description = "The AWS region where the Transit Gateway is deployed."
  value       = data.aws_region.current.name
}

output "aws_account_id" {
  description = "The AWS account ID that owns the Transit Gateway."
  value       = data.aws_caller_identity.current.account_id
}
