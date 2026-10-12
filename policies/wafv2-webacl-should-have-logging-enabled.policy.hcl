# Copyright IBM Corp. 2026

# AWS WAF web ACL logging should be enabled
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.68.0, < 7.0.0"
    }
  }
}


resource_policy "aws_wafv2_web_acl" "logging_enabled" {
  locals {
    web_acl_arn = core::try(attrs.arn, null)
    logging_configs = local.web_acl_arn != null ? core::getresources("aws_wafv2_web_acl_logging_configuration", {
      resource_arn = local.web_acl_arn
    }) : []
    has_logging_config = core::length(local.logging_configs) > 0
  }

  enforcement_level = "advisory"
  enforce {
    condition     = local.has_logging_config
    error_message = "WAFv2 Web ACLs should have logging enabled"
  }
}


