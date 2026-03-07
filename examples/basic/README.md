# Basic Example - Simple 2-VPC Transit Gateway

This example creates a Transit Gateway connecting two VPCs using default route tables for full mesh connectivity.

## Architecture

```
  +--------+          +------------------+          +--------+
  | VPC A  |--------->| Transit Gateway  |<---------| VPC B  |
  | 10.1.0 |          | (Default RT)     |          | 10.2.0 |
  +--------+          +------------------+          +--------+
```

Both VPCs are attached to the Transit Gateway and use the default route table, enabling bidirectional communication.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Resources Created

- 1 Transit Gateway
- 2 VPC Attachments (one per VPC)
- 2 VPCs with private subnets (supporting resources)

## Estimated Cost

- Transit Gateway: ~$36/month (per attachment hour)
- VPC Attachments: ~$0.05/hour per attachment
- Data processing: $0.02/GB

See [AWS Transit Gateway Pricing](https://aws.amazon.com/transit-gateway/pricing/) for current rates.
