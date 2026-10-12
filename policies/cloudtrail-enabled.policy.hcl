# Policy: CloudTrail.3
# Copyright IBM Corp. 2026

# CloudTrail trails should be enabled (logging must not be turned off)

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

input "cloudtrail-enabled-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "aws_cloudtrail" "logging_enabled" {
  enforcement_level = input.cloudtrail-enabled-enforcement-level
  locals {
    enable_logging = core::try(attrs.enable_logging, true)
    is_compliant   = local.enable_logging != false
  }

  enforce {
    condition     = local.is_compliant
    error_message = "Attribute 'enable_logging' must not be set to false for 'aws_cloudtrail' resources."
  }
}
