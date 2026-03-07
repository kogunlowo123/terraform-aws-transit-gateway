################################################################################
# Inter-Region Transit Gateway Peering Sub-Module
#
# Creates a peering attachment between two Transit Gateways in different AWS
# regions. Enables cross-region connectivity for global network architectures.
# The peering must be accepted in the peer region (use the accepter resource
# or enable auto-accept).
################################################################################

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.20.0"
      configuration_aliases = [aws.peer]
    }
  }
}

################################################################################
# Data Sources
################################################################################

data "aws_region" "peer" {
  provider = aws.peer
}

data "aws_caller_identity" "peer" {
  provider = aws.peer
}

################################################################################
# Transit Gateway Peering Attachment (Requester Side)
################################################################################

resource "aws_ec2_transit_gateway_peering_attachment" "this" {
  transit_gateway_id      = var.transit_gateway_id
  peer_transit_gateway_id = var.peer_transit_gateway_id
  peer_region             = data.aws_region.peer.name
  peer_account_id         = var.peer_account_id != null ? var.peer_account_id : data.aws_caller_identity.peer.account_id

  tags = merge(
    var.tags,
    {
      Name = var.name
      Side = "requester"
    }
  )
}

################################################################################
# Transit Gateway Peering Attachment Accepter (Peer Side)
################################################################################

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "this" {
  count    = var.auto_accept ? 1 : 0
  provider = aws.peer

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.this.id

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-accepter"
      Side = "accepter"
    }
  )
}

################################################################################
# Route Table Association for Peering (Requester Side)
################################################################################

resource "aws_ec2_transit_gateway_route_table_association" "requester" {
  count = var.requester_route_table_id != null ? 1 : 0

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.this.id
  transit_gateway_route_table_id = var.requester_route_table_id
}

################################################################################
# Route Table Association for Peering (Peer/Accepter Side)
################################################################################

resource "aws_ec2_transit_gateway_route_table_association" "accepter" {
  count    = var.auto_accept && var.accepter_route_table_id != null ? 1 : 0
  provider = aws.peer

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.this.id
  transit_gateway_route_table_id = var.accepter_route_table_id
}

################################################################################
# Static Routes (Requester Side)
################################################################################

resource "aws_ec2_transit_gateway_route" "requester" {
  for_each = var.requester_route_table_id != null ? toset(var.requester_routes) : toset([])

  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.this.id
  transit_gateway_route_table_id = var.requester_route_table_id
}

################################################################################
# Static Routes (Peer/Accepter Side)
################################################################################

resource "aws_ec2_transit_gateway_route" "accepter" {
  for_each = var.auto_accept && var.accepter_route_table_id != null ? toset(var.accepter_routes) : toset([])
  provider = aws.peer

  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.this.id
  transit_gateway_route_table_id = var.accepter_route_table_id
}
