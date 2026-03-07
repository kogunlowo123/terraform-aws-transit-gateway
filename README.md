# terraform-aws-transit-gateway

Enterprise-grade AWS Transit Gateway Terraform module with VPC attachments, custom route tables, RAM sharing, and inter-region peering support.

## Architecture

```
                                 AWS Cloud
    +----------------------------------------------------------------+
    |                                                                |
    |  Account A (Hub)                Account B (Spoke)              |
    |  +----------------------------+  +-------------------------+  |
    |  |                            |  |                         |  |
    |  |  +--------+  +--------+   |  |   +--------+            |  |
    |  |  | VPC A  |  | VPC B  |   |  |   | VPC C  |            |  |
    |  |  |10.1/16 |  |10.2/16 |   |  |   |10.3/16 |            |  |
    |  |  +---+----+  +---+----+   |  |   +---+----+            |  |
    |  |      |           |        |  |       |                  |  |
    |  |  +---+-----------+----+   |  |   +---+----+             |  |
    |  |  |  Transit Gateway   |<--RAM--->| TGW    |             |  |
    |  |  |                    |   |  |   | Attach |             |  |
    |  |  | +------+ +------+ |   |  |   +--------+             |  |
    |  |  | |Prod  | |Dev   | |   |  |                         |  |
    |  |  | |RT    | |RT    | |   |  |                         |  |
    |  |  | +------+ +------+ |   |  |                         |  |
    |  |  +--------------------+   |  |                         |  |
    |  +----------------------------+  +-------------------------+  |
    |                                                                |
    |  Region us-east-1               Region eu-west-1              |
    |  +------------------------+     +------------------------+    |
    |  | Transit Gateway A      |<--->| Transit Gateway B      |    |
    |  | (Inter-Region Peering) |     | (Inter-Region Peering) |    |
    |  +------------------------+     +------------------------+    |
    +----------------------------------------------------------------+
```

## Features

- **Transit Gateway**: Fully configurable with ASN, DNS, ECMP, and multicast support
- **VPC Attachments**: Dynamic VPC attachments with per-attachment configuration
- **Custom Route Tables**: Network segmentation with custom route tables, associations, and propagations
- **Static Routes**: Support for both forwarding routes and blackhole routes
- **RAM Sharing**: Cross-account Transit Gateway sharing via AWS Resource Access Manager
- **Sub-Modules**: Reusable spoke attachment and inter-region peering modules
- **Production Ready**: Input validation, comprehensive tagging, and full documentation

## Usage

### Basic - Two VPC Connectivity

```hcl
module "transit_gateway" {
  source = "kogunlowo123/transit-gateway/aws"

  name        = "my-tgw"
  description = "Transit Gateway for VPC connectivity"

  vpc_attachments = {
    vpc_a = {
      vpc_id     = "vpc-aaa"
      subnet_ids = ["subnet-aaa1", "subnet-aaa2"]
    }
    vpc_b = {
      vpc_id     = "vpc-bbb"
      subnet_ids = ["subnet-bbb1", "subnet-bbb2"]
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### Advanced - Network Segmentation with Custom Route Tables

```hcl
module "transit_gateway" {
  source = "kogunlowo123/transit-gateway/aws"

  name = "segmented-tgw"

  enable_default_route_table_association = false
  enable_default_route_table_propagation = false

  vpc_attachments = {
    production = {
      vpc_id     = "vpc-prod"
      subnet_ids = ["subnet-prod-1a", "subnet-prod-1b"]
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false
    }
    development = {
      vpc_id     = "vpc-dev"
      subnet_ids = ["subnet-dev-1a", "subnet-dev-1b"]
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false
    }
  }

  route_tables = {
    production  = { name = "production-rt" }
    development = { name = "development-rt" }
  }

  route_table_associations = {
    prod_assoc = { route_table_key = "production",  attachment_key = "production" }
    dev_assoc  = { route_table_key = "development", attachment_key = "development" }
  }

  route_table_propagations = {
    prod_to_dev = { route_table_key = "development", attachment_key = "production" }
    dev_to_prod = { route_table_key = "production",  attachment_key = "development" }
  }

  # Blackhole route to drop traffic to unused address space
  routes = [
    {
      destination_cidr = "172.16.0.0/12"
      route_table_key  = "production"
      blackhole        = true
    }
  ]

  tags = {
    Environment = "multi-env"
  }
}
```

### Cross-Account Sharing with RAM

```hcl
module "transit_gateway" {
  source = "kogunlowo123/transit-gateway/aws"

  name = "shared-tgw"

  enable_auto_accept_shared_attachments = true

  vpc_attachments = {
    hub = {
      vpc_id     = "vpc-hub"
      subnet_ids = ["subnet-hub-1a", "subnet-hub-1b"]
    }
  }

  ram_principals = [
    "123456789012",  # Spoke account
    "arn:aws:organizations::111111111111:organization/o-abc123",  # Entire org
  ]

  tags = {
    Environment = "hub"
  }
}
```

## Sub-Modules

### spoke-attachment

Reusable module for attaching spoke VPCs with optional route table association, propagation, and VPC route creation.

```hcl
module "spoke" {
  source = "kogunlowo123/transit-gateway/aws//modules/spoke-attachment"

  name               = "spoke-vpc"
  transit_gateway_id = module.transit_gateway.transit_gateway_id
  vpc_id             = "vpc-spoke"
  subnet_ids         = ["subnet-spoke-1a", "subnet-spoke-1b"]

  route_table_id          = module.transit_gateway.route_table_ids["production"]
  propagation_route_table_ids = [module.transit_gateway.route_table_ids["shared"]]
}
```

### inter-region-peering

Creates Transit Gateway peering between two regions with automatic acceptance, route table associations, and static routes.

```hcl
module "peering" {
  source = "kogunlowo123/transit-gateway/aws//modules/inter-region-peering"

  providers = {
    aws      = aws
    aws.peer = aws.eu_west
  }

  name                    = "us-to-eu"
  transit_gateway_id      = module.tgw_us.transit_gateway_id
  peer_transit_gateway_id = module.tgw_eu.transit_gateway_id

  requester_route_table_id = module.tgw_us.route_table_ids["main"]
  accepter_route_table_id  = module.tgw_eu.route_table_ids["main"]

  requester_routes = ["10.100.0.0/16"]
  accepter_routes  = ["10.0.0.0/16"]
}
```

## Requirements

| Name | Version |
|------|---------|
| [terraform](#requirement\_terraform) | >= 1.5.0 |
| [aws](#requirement\_aws) | >= 5.20.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `name` | Name for the Transit Gateway and associated resources | `string` | n/a | yes |
| `description` | Description of the Transit Gateway | `string` | `""` | no |
| `amazon_side_asn` | Private ASN for the Amazon side of BGP session | `number` | `64512` | no |
| `enable_auto_accept_shared_attachments` | Auto-accept cross-account attachment requests | `bool` | `false` | no |
| `enable_default_route_table_association` | Auto-associate attachments with default route table | `bool` | `true` | no |
| `enable_default_route_table_propagation` | Auto-propagate routes to default route table | `bool` | `true` | no |
| `enable_dns_support` | Enable DNS resolution across attached VPCs | `bool` | `true` | no |
| `enable_vpn_ecmp_support` | Enable ECMP for VPN connections | `bool` | `true` | no |
| `enable_multicast_support` | Enable multicast on the Transit Gateway | `bool` | `false` | no |
| `vpc_attachments` | Map of VPC attachment configurations | `map(object({...}))` | `{}` | no |
| `route_tables` | Map of custom route table configurations | `map(object({name=string}))` | `{}` | no |
| `routes` | List of static routes (forwarding and blackhole) | `list(object({...}))` | `[]` | no |
| `route_table_associations` | Map of route table associations | `map(object({...}))` | `{}` | no |
| `route_table_propagations` | Map of route table propagations | `map(object({...}))` | `{}` | no |
| `ram_principals` | AWS account IDs or organization ARNs for RAM sharing | `list(string)` | `[]` | no |
| `tags` | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `transit_gateway_id` | The ID of the Transit Gateway |
| `transit_gateway_arn` | The ARN of the Transit Gateway |
| `transit_gateway_owner_id` | The AWS account ID of the Transit Gateway owner |
| `transit_gateway_association_default_route_table_id` | The default association route table ID |
| `transit_gateway_propagation_default_route_table_id` | The default propagation route table ID |
| `vpc_attachment_ids` | Map of VPC attachment IDs keyed by attachment name |
| `vpc_attachment_details` | Map of VPC attachment details (ID, VPC ID, subnet IDs) |
| `route_table_ids` | Map of custom route table IDs |
| `ram_resource_share_id` | RAM resource share ID (null if not enabled) |
| `ram_resource_share_arn` | RAM resource share ARN (null if not enabled) |
| `aws_region` | AWS region of the Transit Gateway |
| `aws_account_id` | AWS account ID owning the Transit Gateway |

## Security Considerations

- **Network Segmentation**: Use custom route tables to isolate environments. Never rely solely on default route tables in production.
- **Blackhole Routes**: Use blackhole routes to explicitly drop traffic to unused or restricted CIDR ranges.
- **Appliance Mode**: Enable appliance mode for VPC attachments hosting stateful network appliances (firewalls, IDS/IPS) to ensure symmetric routing.
- **RAM Sharing**: When sharing via RAM, use organization-level sharing with SCPs for governance. Avoid sharing with individual accounts when possible.
- **Auto-Accept**: Only enable `auto_accept_shared_attachments` when you have strong governance (SCPs) in place. Otherwise, manually approve each attachment.
- **DNS Support**: Be aware that enabling DNS support allows cross-VPC DNS resolution, which may expose internal service names.
- **Least Privilege**: Use route table associations and propagations to implement least-privilege network access between VPCs.
- **Monitoring**: Enable VPC Flow Logs on all attached VPCs and Transit Gateway Flow Logs for network visibility.

## Cost Estimation

| Component | Unit | Price (us-east-1) |
|-----------|------|-------------------|
| Transit Gateway | Per hour | $0.05 |
| VPC Attachment | Per hour per attachment | $0.05 |
| Data Processing | Per GB | $0.02 |
| Peering Attachment | Per hour per attachment | $0.05 |
| Cross-region data | Per GB | Standard data transfer rates |

**Example**: A Transit Gateway with 5 VPC attachments processing 1 TB/month:

- TGW: $0.05 x 730 hours = $36.50
- Attachments: 5 x $0.05 x 730 = $182.50
- Data: 1,000 GB x $0.02 = $20.00
- **Total: ~$239/month**

## References

- [AWS Transit Gateway Documentation](https://docs.aws.amazon.com/vpc/latest/tgw/what-is-transit-gateway.html)
- [Transit Gateway Design Best Practices](https://docs.aws.amazon.com/vpc/latest/tgw/tgw-best-design-practices.html)
- [Transit Gateway Network Manager](https://docs.aws.amazon.com/vpc/latest/tgw/what-is-network-manager.html)
- [AWS RAM User Guide](https://docs.aws.amazon.com/ram/latest/userguide/what-is.html)
- [Terraform AWS Provider - Transit Gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway)
- [AWS Transit Gateway Pricing](https://aws.amazon.com/transit-gateway/pricing/)
- [Centralized Inspection Architecture](https://docs.aws.amazon.com/prescriptive-guidance/latest/inline-traffic-inspection-third-party-appliances/architecture.html)

## Examples

- [Basic](examples/basic/) - Simple 2-VPC Transit Gateway
- [Advanced](examples/advanced/) - Multi-VPC with custom route tables and network segmentation
- [Complete](examples/complete/) - Full enterprise with RAM sharing, inspection VPC, and blackhole routes

## License

MIT Licensed. See [LICENSE](LICENSE) for full details.
