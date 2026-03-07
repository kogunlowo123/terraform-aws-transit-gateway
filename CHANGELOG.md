# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-15

### Added

- AWS Transit Gateway resource with full configuration support (ASN, DNS, ECMP, multicast).
- Dynamic VPC attachments with per-attachment configuration (appliance mode, DNS, route table overrides).
- Custom Transit Gateway route tables for network segmentation.
- Static route support including blackhole routes for traffic filtering.
- Route table associations and propagations for granular traffic control.
- AWS RAM resource sharing for cross-account Transit Gateway access.
- Spoke attachment sub-module for reusable VPC attachment patterns.
- Inter-region peering sub-module with automatic acceptance and bidirectional route configuration.
- Basic example demonstrating simple 2-VPC connectivity.
- Advanced example with custom route tables and network segmentation.
- Complete example with enterprise features (inspection VPC, blackhole routes, RAM sharing).
- Comprehensive input validation for ASN ranges and CIDR blocks.
- Full documentation with architecture diagrams, security considerations, and cost estimation.

[1.0.0]: https://github.com/kogunlowo123/terraform-aws-transit-gateway/releases/tag/v1.0.0
