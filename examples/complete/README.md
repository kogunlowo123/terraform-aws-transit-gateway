# Complete Example - Enterprise Transit Gateway

This example demonstrates a full enterprise Transit Gateway deployment with network segmentation, centralized inspection, blackhole routes, and cross-account sharing via AWS RAM.

## Architecture

```
                          +-------------------+
                          | Shared Services   |
                          | (10.0.0.0/16)     |
                          +---------+---------+
                                    |
                          +---------+---------+
                          |  Transit Gateway  |
                          |                   |
                +----+----+----+----+----+----+----+
                |         |         |         |    |
         +------+--+ +---+----+ +--+-----+ +-+----+---+
         |Inspection| |Prod A  | |Prod B  | |Staging   |
         |10.5.0/16 | |10.10/16| |10.11/16| |10.20/16  |
         |(Firewall)| +--------+ +--------+ +----------+
         +---------+
```

## Network Segmentation Matrix

| Source | Shared | Inspection | Prod A | Prod B | Staging |
|--------|--------|------------|--------|--------|---------|
| Shared | - | Yes | Yes | Yes | Yes |
| Inspection | Yes | - | Yes | Yes | Yes |
| Prod A | Yes | Yes | - | Yes | No |
| Prod B | Yes | Yes | Yes | - | No |
| Staging | Yes | Yes | No | No | - |

## Key Features Demonstrated

1. **Centralized Inspection**: All production and staging traffic routes through the inspection VPC via default routes.
2. **Blackhole Routes**: RFC 1918 space (172.16.0.0/12) is blackholed. Staging is explicitly blocked from production CIDRs.
3. **Appliance Mode**: Enabled on the inspection VPC attachment for symmetric routing through stateful firewalls.
4. **RAM Sharing**: Transit Gateway shared with other AWS accounts for cross-account VPC attachments.
5. **Custom Route Tables**: Separate route tables per environment for granular traffic control.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Cost Estimation

| Resource | Estimated Monthly Cost |
|----------|----------------------|
| Transit Gateway (per region) | $36.00 |
| VPC Attachments (5x) | ~$182.50 |
| Data Processing (varies) | $0.02/GB |
| **Total (base)** | **~$218.50/month** |

Note: Actual costs depend on data transfer volume. See [AWS Pricing](https://aws.amazon.com/transit-gateway/pricing/).
