# Spoke VPC Attachment Sub-Module

This sub-module creates a Transit Gateway VPC attachment for a spoke VPC in a hub-and-spoke network topology. It handles the attachment itself, optional route table association and propagation, and optional VPC route table entries pointing back to the Transit Gateway.

## Usage

```hcl
module "spoke_attachment" {
  source = "../../modules/spoke-attachment"

  name               = "spoke-vpc-production"
  transit_gateway_id = "tgw-0123456789abcdef0"
  vpc_id             = "vpc-0123456789abcdef0"
  subnet_ids         = ["subnet-aaa", "subnet-bbb", "subnet-ccc"]

  # Associate with a custom route table instead of the default
  transit_gateway_default_route_table_association = false
  route_table_id = "tgw-rtb-0123456789abcdef0"

  # Propagate routes to specific route tables
  propagation_route_table_ids = ["tgw-rtb-0123456789abcdef0"]

  # Add routes in VPC route tables pointing to the TGW
  vpc_route_table_ids = ["rtb-aaa", "rtb-bbb"]
  destination_cidrs   = ["10.0.0.0/8", "172.16.0.0/12"]

  tags = {
    Environment = "production"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Name tag for the VPC attachment | `string` | n/a | yes |
| transit_gateway_id | ID of the Transit Gateway | `string` | n/a | yes |
| vpc_id | ID of the spoke VPC | `string` | n/a | yes |
| subnet_ids | List of subnet IDs (one per AZ) | `list(string)` | n/a | yes |
| appliance_mode_support | Enable appliance mode for symmetric routing | `bool` | `false` | no |
| dns_support | Enable DNS support | `bool` | `true` | no |
| route_table_id | Custom route table ID to associate with | `string` | `null` | no |
| propagation_route_table_ids | Route table IDs to propagate routes into | `list(string)` | `[]` | no |
| vpc_route_table_ids | VPC route table IDs for TGW routes | `list(string)` | `null` | no |
| destination_cidrs | Destination CIDRs for VPC routes | `list(string)` | `[]` | no |
| tags | Tags for the attachment | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| attachment_id | The ID of the Transit Gateway VPC attachment |
| vpc_id | The VPC ID of the attached VPC |
| subnet_ids | The subnet IDs used by the attachment |
