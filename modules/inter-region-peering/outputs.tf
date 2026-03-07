################################################################################
# Outputs
################################################################################

output "peering_attachment_id" {
  description = "The ID of the Transit Gateway peering attachment."
  value       = aws_ec2_transit_gateway_peering_attachment.this.id
}

output "peering_attachment_state" {
  description = "The state of the peering attachment (e.g., pendingAcceptance, available)."
  value       = aws_ec2_transit_gateway_peering_attachment.this.state
}

output "peer_region" {
  description = "The AWS region of the peer Transit Gateway."
  value       = data.aws_region.peer.name
}

output "peer_account_id" {
  description = "The AWS account ID of the peer Transit Gateway owner."
  value       = aws_ec2_transit_gateway_peering_attachment.this.peer_account_id
}
