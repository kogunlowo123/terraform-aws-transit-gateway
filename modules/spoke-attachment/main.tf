################################################################################
# Spoke VPC Attachment Sub-Module
#
# Creates a Transit Gateway VPC attachment for a spoke VPC, including optional
# route table association and propagation. Designed for hub-and-spoke topologies
# where spoke VPCs need controlled connectivity through the Transit Gateway.
################################################################################

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.20.0"
    }
  }
}

################################################################################
# VPC Attachment
################################################################################

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = var.vpc_id
  subnet_ids         = var.subnet_ids

  appliance_mode_support                          = var.appliance_mode_support ? "enable" : "disable"
  dns_support                                     = var.dns_support ? "enable" : "disable"
  transit_gateway_default_route_table_association = var.transit_gateway_default_route_table_association
  transit_gateway_default_route_table_propagation = var.transit_gateway_default_route_table_propagation

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

################################################################################
# Route Table Association (Optional)
################################################################################

resource "aws_ec2_transit_gateway_route_table_association" "this" {
  count = var.route_table_id != null ? 1 : 0

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = var.route_table_id
}

################################################################################
# Route Table Propagation (Optional)
################################################################################

resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  for_each = toset(var.propagation_route_table_ids)

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = each.value
}

################################################################################
# VPC Route to Transit Gateway (Optional)
################################################################################

resource "aws_route" "this" {
  for_each = var.vpc_route_table_ids != null ? {
    for pair in setproduct(var.vpc_route_table_ids, var.destination_cidrs) :
    "${pair[0]}-${pair[1]}" => {
      route_table_id = pair[0]
      cidr_block     = pair[1]
    }
  } : {}

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.cidr_block
  transit_gateway_id     = var.transit_gateway_id
}
