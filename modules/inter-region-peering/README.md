# Inter-Region Transit Gateway Peering Sub-Module

This sub-module creates a Transit Gateway peering attachment between two Transit Gateways in different AWS regions. It supports automatic acceptance, route table associations on both sides, and static route creation for cross-region traffic.

## Architecture

```
  Region A (Requester)              Region B (Accepter)
  +------------------+              +------------------+
  |  Transit Gateway |<-- Peering -->|  Transit Gateway |
  |  tgw-aaa         |  Attachment  |  tgw-bbb         |
  +------------------+              +------------------+
```

## Usage

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "eu_west"
  region = "eu-west-1"
}

module "tgw_peering" {
  source = "../../modules/inter-region-peering"

  providers = {
    aws      = aws
    aws.peer = aws.eu_west
  }

  name                    = "us-east-to-eu-west"
  transit_gateway_id      = "tgw-aaa"
  peer_transit_gateway_id = "tgw-bbb"
  auto_accept             = true

  requester_route_table_id = "tgw-rtb-aaa"
  accepter_route_table_id  = "tgw-rtb-bbb"

  requester_routes = ["10.1.0.0/16", "10.2.0.0/16"]
  accepter_routes  = ["10.10.0.0/16", "10.20.0.0/16"]

  tags = {
    Environment = "production"
  }
}
```

## Provider Configuration

This module requires two AWS provider configurations:
- `aws` - The provider for the requester (local) region.
- `aws.peer` - The provider for the peer (remote) region.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Name tag for the peering attachment | `string` | n/a | yes |
| transit_gateway_id | ID of the local Transit Gateway | `string` | n/a | yes |
| peer_transit_gateway_id | ID of the remote Transit Gateway | `string` | n/a | yes |
| peer_account_id | AWS account ID of the peer TGW owner | `string` | `null` | no |
| auto_accept | Auto-accept the peering on the peer side | `bool` | `true` | no |
| requester_route_table_id | Route table ID on requester side | `string` | `null` | no |
| accepter_route_table_id | Route table ID on accepter side | `string` | `null` | no |
| requester_routes | CIDRs for requester-side static routes | `list(string)` | `[]` | no |
| accepter_routes | CIDRs for accepter-side static routes | `list(string)` | `[]` | no |
| tags | Tags for all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| peering_attachment_id | The ID of the peering attachment |
| peering_attachment_state | The state of the peering attachment |
| peer_region | The AWS region of the peer Transit Gateway |
| peer_account_id | The AWS account ID of the peer TGW owner |
