# Copyright IBM Corp. 2026

# CloudWatch alarm actions should be activated

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.68.0, < 7.0.0"
    }
  }
}

resource_policy "aws_cloudwatch_metric_alarm" "actions_enabled" {
  locals {
    actions_enabled_raw = core::try(attrs.actions_enabled, null)
    actions_enabled     = local.actions_enabled_raw == null ? true : local.actions_enabled_raw
  }

  enforcement_level = "advisory"
  enforce {
    condition     = local.actions_enabled == true
    error_message = "CloudWatch alarms should have actions enabled. Set actions_enabled = true on this aws_cloudwatch_metric_alarm."
  }
}

resource_policy "aws_cloudwatch_composite_alarm" "actions_enabled" {
  locals {
    actions_enabled_raw = core::try(attrs.actions_enabled, null)
    actions_enabled     = local.actions_enabled_raw == null ? true : local.actions_enabled_raw
  }

  enforcement_level = "advisory"
  enforce {
    condition     = local.actions_enabled == true
    error_message = "CloudWatch alarms should have actions enabled. Set actions_enabled = true on this aws_cloudwatch_composite_alarm."
  }
}


