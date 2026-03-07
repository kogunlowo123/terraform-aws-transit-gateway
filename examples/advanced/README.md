# Advanced Example - Multi-VPC with Custom Route Tables

This example demonstrates network segmentation using custom Transit Gateway route tables. Production and development environments are isolated from each other while both can access shared services.

## Architecture

```
                    +---------------------+
                    |   Shared Services   |
                    |   VPC (10.0.0.0/16) |
                    +----------+----------+
                               |
                    +----------+----------+
                    |   Transit Gateway   |
                    | +-------+ +-------+ |
                    | |Prod RT| |Dev RT | |
                    | +---+---+ +---+---+ |
                    +-----|---------|------+
                          |         |
              +-----------+    +----+--------+
              |                |             |
  +-----------+-------+  +----+------------+
  | Production VPC    |  | Development VPC |
  | (10.10.0.0/16)    |  | (10.20.0.0/16)  |
  +-------------------+  +-----------------+
```

## Network Segmentation

| Source | Destination | Allowed |
|--------|-------------|---------|
| Production | Shared Services | Yes |
| Production | Development | No |
| Development | Shared Services | Yes |
| Development | Production | No |
| Shared Services | Production | Yes |
| Shared Services | Development | Yes |

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Resources Created

- 1 Transit Gateway
- 3 VPC Attachments
- 3 Custom Route Tables
- 4 Route Table Propagations
- 3 Route Table Associations
- 3 VPCs with private subnets (supporting resources)
