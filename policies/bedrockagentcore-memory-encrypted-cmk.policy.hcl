# Policy: BedrockAgentCore.3
# Copyright IBM Corp. 2026

# Bedrock AgentCore Memory should be encrypted with customer managed AWS KMS keys

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

input "bedrockagentcore-memory-encrypted-cmk-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "aws_bedrockagentcore_memory" "encrypted_with_cmk" {
  enforcement_level = input.bedrockagentcore-memory-encrypted-cmk-enforcement-level
  locals {
    raw_key = core::try(attrs.encryption_key_arn, null)
    key_arn = local.raw_key == null ? "" : local.raw_key
    key_set = core::length(core::regexall("^.+$", local.key_arn)) > 0
    # AWS managed key aliases (alias/aws/...) are not customer managed keys
    is_aws_managed = core::length(core::regexall("alias/aws/", local.key_arn)) > 0
    is_compliant   = local.key_set && !local.is_aws_managed
  }

  enforce {
    condition     = local.is_compliant
    error_message = "Attribute 'encryption_key_arn' must be set to a customer managed KMS key for 'aws_bedrockagentcore_memory' resources."
  }
}
