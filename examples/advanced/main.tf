################################################################################
# Advanced Example - Multi-VPC with Custom Route Tables
#
# This example demonstrates network segmentation using custom route tables.
# Production and development VPCs are isolated from each other while both
# can reach the shared services VPC.
################################################################################

provider "aws" {
  region = "us-east-1"
}

################################################################################
# Supporting VPC Resources
################################################################################

module "vpc_shared" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "shared-services"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  tags = { Environment = "shared" }
}

module "vpc_prod" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "production"
  cidr = "10.10.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]

  tags = { Environment = "production" }
}

module "vpc_dev" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "development"
  cidr = "10.20.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]

  tags = { Environment = "development" }
}

################################################################################
# Transit Gateway with Custom Route Tables
################################################################################

module "transit_gateway" {
  source = "../../"

  name        = "advanced-tgw"
  description = "Multi-VPC Transit Gateway with network segmentation"

  # Disable default route table to enforce custom routing
  enable_default_route_table_association = false
  enable_default_route_table_propagation = false

  vpc_attachments = {
    shared = {
      vpc_id     = module.vpc_shared.vpc_id
      subnet_ids = module.vpc_shared.private_subnets
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false
      tags = { Purpose = "shared-services" }
    }
    production = {
      vpc_id     = module.vpc_prod.vpc_id
      subnet_ids = module.vpc_prod.private_subnets
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false
      tags = { Purpose = "production-workloads" }
    }
    development = {
      vpc_id     = module.vpc_dev.vpc_id
      subnet_ids = module.vpc_dev.private_subnets
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false
      tags = { Purpose = "development-workloads" }
    }
  }

  # Custom route tables for network segmentation
  route_tables = {
    shared = {
      name = "shared-services-rt"
    }
    production = {
      name = "production-rt"
    }
    development = {
      name = "development-rt"
    }
  }

  # Route table associations - each VPC gets its own route table
  route_table_associations = {
    shared_assoc = {
      route_table_key = "shared"
      attachment_key  = "shared"
    }
    prod_assoc = {
      route_table_key = "production"
      attachment_key  = "production"
    }
    dev_assoc = {
      route_table_key = "development"
      attachment_key  = "development"
    }
  }

  # Route table propagations - control which VPCs can see each other
  # Production can reach shared, but NOT development
  # Development can reach shared, but NOT production
  # Shared can reach both production and development
  route_table_propagations = {
    shared_to_prod = {
      route_table_key = "production"
      attachment_key  = "shared"
    }
    shared_to_dev = {
      route_table_key = "development"
      attachment_key  = "shared"
    }
    prod_to_shared = {
      route_table_key = "shared"
      attachment_key  = "production"
    }
    dev_to_shared = {
      route_table_key = "shared"
      attachment_key  = "development"
    }
  }

  tags = {
    Environment = "multi-env"
    Example     = "advanced"
  }
}

################################################################################
# Outputs
################################################################################

output "transit_gateway_id" {
  value = module.transit_gateway.transit_gateway_id
}

output "route_table_ids" {
  value = module.transit_gateway.route_table_ids
}

output "vpc_attachment_ids" {
  value = module.transit_gateway.vpc_attachment_ids
}
