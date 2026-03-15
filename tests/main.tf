module "transit_gateway" {
  source = "../"

  name        = "test-tgw"
  description = "Test Transit Gateway"

  amazon_side_asn                        = 64512
  enable_auto_accept_shared_attachments  = false
  enable_default_route_table_association = true
  enable_default_route_table_propagation = true
  enable_dns_support                     = true
  enable_vpn_ecmp_support                = true
  enable_multicast_support               = false

  vpc_attachments = {}
  route_tables    = {}
  routes          = []

  route_table_associations = {}
  route_table_propagations = {}
  ram_principals           = []

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
  }
}
