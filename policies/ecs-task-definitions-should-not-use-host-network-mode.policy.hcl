# Copyright IBM Corp. 2026

# ECS task definitions should not use host network mode
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.68.0, < 7.0.0"
    }
  }
}

resource_policy "aws_ecs_task_definition" "ecs_task_definitions_should_not_use_host_network_mode" {
  locals {
    # Missing or null network_mode is treated as "" (not a violation)
    network_mode_raw = core::try(attrs.network_mode, null)
    network_mode     = local.network_mode_raw == null ? "" : local.network_mode_raw
  }

  enforcement_level = "advisory"
  enforce {
    condition     = local.network_mode != "host"
    error_message = "ECS task definitions should not use 'host' network mode for security reasons."
  }
}


