################################################################################
# Outputs
################################################################################

output "attachment_id" {
  description = "The ID of the Transit Gateway VPC attachment."
  value       = aws_ec2_transit_gateway_vpc_attachment.this.id
}

output "vpc_id" {
  description = "The VPC ID of the attached VPC."
  value       = aws_ec2_transit_gateway_vpc_attachment.this.vpc_id
}

output "subnet_ids" {
  description = "The subnet IDs used by the attachment."
  value       = aws_ec2_transit_gateway_vpc_attachment.this.subnet_ids
}
