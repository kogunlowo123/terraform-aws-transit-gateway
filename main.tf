################################################################################
# Transit Gateway
################################################################################

resource "aws_ec2_transit_gateway" "this" {
  description = var.description != "" ? var.description : "Transit Gateway - ${var.name}"

  amazon_side_asn                 = var.amazon_side_asn
  auto_accept_shared_attachments  = var.enable_auto_accept_shared_attachments ? "enable" : "disable"
  default_route_table_association = var.enable_default_route_table_association ? "enable" : "disable"
  default_route_table_propagation = var.enable_default_route_table_propagation ? "enable" : "disable"
  dns_support                     = var.enable_dns_support ? "enable" : "disable"
  vpn_ecmp_support                = var.enable_vpn_ecmp_support ? "enable" : "disable"
  multicast_support               = var.enable_multicast_support ? "enable" : "disable"

  tags = merge(
    local.common_tags,
    {
      Name = var.name
    }
  )
}

################################################################################
# VPC Attachments
################################################################################

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  for_each = var.vpc_attachments

  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = each.value.vpc_id
  subnet_ids         = each.value.subnet_ids

  appliance_mode_support = each.value.appliance_mode_support ? "enable" : "disable"
  dns_support            = each.value.dns_support ? "enable" : "disable"

  transit_gateway_default_route_table_association = each.value.transit_gateway_default_route_table_association
  transit_gateway_default_route_table_propagation = each.value.transit_gateway_default_route_table_propagation

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-${each.key}"
    },
    each.value.tags
  )
}

################################################################################
# Custom Route Tables
################################################################################

resource "aws_ec2_transit_gateway_route_table" "this" {
  for_each = var.route_tables

  transit_gateway_id = aws_ec2_transit_gateway.this.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-${each.value.name}"
    }
  )
}

################################################################################
# Static Routes
################################################################################

resource "aws_ec2_transit_gateway_route" "this" {
  for_each = local.routes_with_index

  destination_cidr_block         = each.value.destination_cidr
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this[each.value.route_table_key].id

  # For blackhole routes, no attachment is specified
  transit_gateway_attachment_id = each.value.blackhole ? null : aws_ec2_transit_gateway_vpc_attachment.this[each.value.attachment_key].id
  blackhole                    = each.value.blackhole
}

################################################################################
# Route Table Associations
################################################################################

resource "aws_ec2_transit_gateway_route_table_association" "this" {
  for_each = var.route_table_associations

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this[each.value.attachment_key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this[each.value.route_table_key].id
}

################################################################################
# Route Table Propagations
################################################################################

resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  for_each = var.route_table_propagations

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this[each.value.attachment_key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this[each.value.route_table_key].id
}

################################################################################
# Resource Access Manager (RAM) - Cross-Account Sharing
################################################################################

resource "aws_ram_resource_share" "this" {
  count = local.enable_ram_sharing ? 1 : 0

  name                      = "${var.name}-tgw-share"
  allow_external_principals = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-tgw-share"
    }
  )
}

resource "aws_ram_resource_association" "this" {
  count = local.enable_ram_sharing ? 1 : 0

  resource_arn       = aws_ec2_transit_gateway.this.arn
  resource_share_arn = aws_ram_resource_share.this[0].arn
}

resource "aws_ram_principal_association" "this" {
  count = length(var.ram_principals)

  principal          = var.ram_principals[count.index]
  resource_share_arn = aws_ram_resource_share.this[0].arn
}
