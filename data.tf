################################################################################
# Data Sources
################################################################################

# Current AWS region for constructing ARNs and region-specific configurations
data "aws_region" "current" {}

# Current AWS account identity for constructing ARNs and policy references
data "aws_caller_identity" "current" {}
