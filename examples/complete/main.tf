################################################################################
# Complete Example - Enterprise Transit Gateway
#
# Full enterprise deployment with:
# - Multiple VPCs across environments
# - Custom route tables for network segmentation
# - RAM sharing for cross-account access
# - Blackhole routes for security isolation
# - Inspection VPC with appliance mode for centralized traffic inspection
################################################################################

provider "aws" {
  region = "us-east-1"
}

################################################################################
# Supporting VPC Resources
################################################################################

module "vpc_shared_services" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "shared-services"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  tags = { Environment = "shared" }
}

module "vpc_inspection" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "inspection"
  cidr = "10.5.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.5.1.0/24", "10.5.2.0/24", "10.5.3.0/24"]

  tags = { Environment = "security" }
}

module "vpc_production_a" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "production-a"
  cidr = "10.10.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]

  tags = { Environment = "production" }
}

module "vpc_production_b" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "production-b"
  cidr = "10.11.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.11.1.0/24", "10.11.2.0/24", "10.11.3.0/24"]

  tags = { Environment = "production" }
}

module "vpc_staging" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "staging"
  cidr = "10.20.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]

  tags = { Environment = "staging" }
}

################################################################################
# Transit Gateway - Enterprise Configuration
################################################################################

module "transit_gateway" {
  source = "../../"

  name        = "enterprise-tgw"
  description = "Enterprise Transit Gateway with full network segmentation"

  amazon_side_asn                       = 64512
  enable_auto_accept_shared_attachments = true
  enable_default_route_table_association = false
  enable_default_route_table_propagation = false
  enable_dns_support                     = true
  enable_vpn_ecmp_support                = true
  enable_multicast_support               = false

  # --------------------------------------------------------------------------
  # VPC Attachments
  # --------------------------------------------------------------------------
  vpc_attachments = {
    shared_services = {
      vpc_id     = module.vpc_shared_services.vpc_id
      subnet_ids = module.vpc_shared_services.private_subnets
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false
      tags = { Purpose = "shared-services" }
    }

    inspection = {
      vpc_id                 = module.vpc_inspection.vpc_id
      subnet_ids             = module.vpc_inspection.private_subnets
      appliance_mode_support = true # Enable for stateful firewall appliances
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false
      tags = { Purpose = "centralized-inspection" }
    }

    production_a = {
      vpc_id     = module.vpc_production_a.vpc_id
      subnet_ids = module.vpc_production_a.private_subnets
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false
      tags = { Purpose = "production-workloads" }
    }

    production_b = {
      vpc_id     = module.vpc_production_b.vpc_id
      subnet_ids = module.vpc_production_b.private_subnets
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false
      tags = { Purpose = "production-workloads" }
    }

    staging = {
      vpc_id     = module.vpc_staging.vpc_id
      subnet_ids = module.vpc_staging.private_subnets
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false
      tags = { Purpose = "staging-workloads" }
    }
  }

  # --------------------------------------------------------------------------
  # Custom Route Tables
  # --------------------------------------------------------------------------
  route_tables = {
    shared = {
      name = "shared-services"
    }
    inspection = {
      name = "inspection"
    }
    production = {
      name = "production"
    }
    staging = {
      name = "staging"
    }
  }

  # --------------------------------------------------------------------------
  # Route Table Associations
  # --------------------------------------------------------------------------
  route_table_associations = {
    shared_assoc = {
      route_table_key = "shared"
      attachment_key  = "shared_services"
    }
    inspection_assoc = {
      route_table_key = "inspection"
      attachment_key  = "inspection"
    }
    prod_a_assoc = {
      route_table_key = "production"
      attachment_key  = "production_a"
    }
    prod_b_assoc = {
      route_table_key = "production"
      attachment_key  = "production_b"
    }
    staging_assoc = {
      route_table_key = "staging"
      attachment_key  = "staging"
    }
  }

  # --------------------------------------------------------------------------
  # Route Table Propagations
  # --------------------------------------------------------------------------
  route_table_propagations = {
    # Shared services routes propagate to all environments
    shared_to_prod = {
      route_table_key = "production"
      attachment_key  = "shared_services"
    }
    shared_to_staging = {
      route_table_key = "staging"
      attachment_key  = "shared_services"
    }
    shared_to_inspection = {
      route_table_key = "inspection"
      attachment_key  = "shared_services"
    }

    # Production routes propagate to shared and inspection
    prod_a_to_shared = {
      route_table_key = "shared"
      attachment_key  = "production_a"
    }
    prod_b_to_shared = {
      route_table_key = "shared"
      attachment_key  = "production_b"
    }
    prod_a_to_inspection = {
      route_table_key = "inspection"
      attachment_key  = "production_a"
    }
    prod_b_to_inspection = {
      route_table_key = "inspection"
      attachment_key  = "production_b"
    }

    # Staging routes propagate to shared and inspection
    staging_to_shared = {
      route_table_key = "shared"
      attachment_key  = "staging"
    }
    staging_to_inspection = {
      route_table_key = "inspection"
      attachment_key  = "staging"
    }

    # Inspection routes propagate to all environments
    inspection_to_shared = {
      route_table_key = "shared"
      attachment_key  = "inspection"
    }
    inspection_to_prod = {
      route_table_key = "production"
      attachment_key  = "inspection"
    }
    inspection_to_staging = {
      route_table_key = "staging"
      attachment_key  = "inspection"
    }
  }

  # --------------------------------------------------------------------------
  # Static Routes and Blackholes
  # --------------------------------------------------------------------------
  routes = [
    # Default route through inspection VPC for centralized egress
    {
      destination_cidr = "0.0.0.0/0"
      route_table_key  = "production"
      attachment_key   = "inspection"
      blackhole        = false
    },
    {
      destination_cidr = "0.0.0.0/0"
      route_table_key  = "staging"
      attachment_key   = "inspection"
      blackhole        = false
    },

    # Blackhole routes - drop traffic to RFC 1918 ranges not in use
    # Prevents accidental routing of unallocated address space
    {
      destination_cidr = "172.16.0.0/12"
      route_table_key  = "production"
      blackhole        = true
    },
    {
      destination_cidr = "172.16.0.0/12"
      route_table_key  = "staging"
      blackhole        = true
    },

    # Block staging from reaching production directly
    {
      destination_cidr = "10.10.0.0/16"
      route_table_key  = "staging"
      blackhole        = true
    },
    {
      destination_cidr = "10.11.0.0/16"
      route_table_key  = "staging"
      blackhole        = true
    },
  ]

  # --------------------------------------------------------------------------
  # RAM Sharing for Cross-Account Access
  # --------------------------------------------------------------------------
  ram_principals = [
    "123456789012", # Network account
    "234567890123", # Security account
    # "arn:aws:organizations::123456789012:organization/o-abc123" # Entire org
  ]

  tags = {
    Environment  = "enterprise"
    CostCenter   = "networking"
    Compliance   = "sox"
    Example      = "complete"
  }
}

################################################################################
# Outputs
################################################################################

output "transit_gateway_id" {
  description = "Transit Gateway ID."
  value       = module.transit_gateway.transit_gateway_id
}

output "transit_gateway_arn" {
  description = "Transit Gateway ARN."
  value       = module.transit_gateway.transit_gateway_arn
}

output "vpc_attachment_ids" {
  description = "Map of VPC attachment IDs."
  value       = module.transit_gateway.vpc_attachment_ids
}

output "route_table_ids" {
  description = "Map of custom route table IDs."
  value       = module.transit_gateway.route_table_ids
}

output "ram_resource_share_id" {
  description = "RAM resource share ID for cross-account sharing."
  value       = module.transit_gateway.ram_resource_share_id
}
