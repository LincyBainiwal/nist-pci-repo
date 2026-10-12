# Copyright IBM Corp. 2026

# CloudWatch log groups should be retained for a specified time period

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.68.0, < 7.0.0"
    }
  }
}

resource_policy "aws_cloudwatch_log_group" "retention_period" {
  locals {
    retention_raw = core::try(attrs.retention_in_days, null)
    is_set        = local.retention_raw != null
    # Normalize null to -1 so numeric comparison is always safe (-1 is non-compliant)
    retention     = local.is_set ? local.retention_raw : -1
    is_compliant  = local.is_set && (local.retention == 0 || local.retention >= 365)
  }

  enforcement_level = "advisory"
  enforce {
    condition     = local.is_compliant
    error_message = "CloudWatch Log Groups should have a retention period of at least 365 days or be set to never expire (0)."
  }
}

