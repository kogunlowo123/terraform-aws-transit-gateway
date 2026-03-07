################################################################################
# Basic Example - Simple 2-VPC Transit Gateway
#
# This example demonstrates the simplest Transit Gateway deployment connecting
# two VPCs using default route tables for full mesh connectivity.
################################################################################

provider "aws" {
  region = "us-east-1"
}

################################################################################
# Supporting VPC Resources
################################################################################

module "vpc_a" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "vpc-a"
  cidr = "10.1.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24"]

  tags = {
    Environment = "development"
  }
}

module "vpc_b" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "vpc-b"
  cidr = "10.2.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.2.1.0/24", "10.2.2.0/24"]

  tags = {
    Environment = "development"
  }
}

################################################################################
# Transit Gateway
################################################################################

module "transit_gateway" {
  source = "../../"

  name        = "basic-tgw"
  description = "Basic Transit Gateway connecting two VPCs"

  # Use defaults for simplicity - both VPCs will be associated and propagated
  # to the default route table, enabling full mesh connectivity.
  vpc_attachments = {
    vpc_a = {
      vpc_id     = module.vpc_a.vpc_id
      subnet_ids = module.vpc_a.private_subnets
      tags = {
        Name = "vpc-a-attachment"
      }
    }
    vpc_b = {
      vpc_id     = module.vpc_b.vpc_id
      subnet_ids = module.vpc_b.private_subnets
      tags = {
        Name = "vpc-b-attachment"
      }
    }
  }

  tags = {
    Environment = "development"
    Example     = "basic"
  }
}

################################################################################
# Outputs
################################################################################

output "transit_gateway_id" {
  description = "The Transit Gateway ID."
  value       = module.transit_gateway.transit_gateway_id
}

output "vpc_attachment_ids" {
  description = "Map of VPC attachment IDs."
  value       = module.transit_gateway.vpc_attachment_ids
}
