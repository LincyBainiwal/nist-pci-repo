# Policy: BedrockAgentCore.4
# Copyright IBM Corp. 2026

# Bedrock AgentCore Gateway should be encrypted with customer managed AWS KMS keys

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

input "bedrockagentcore-gateway-encrypted-cmk-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "aws_bedrockagentcore_gateway" "encrypted_with_cmk" {
  enforcement_level = input.bedrockagentcore-gateway-encrypted-cmk-enforcement-level
  locals {
    raw_key = core::try(attrs.kms_key_arn, null)
    key_arn = local.raw_key == null ? "" : local.raw_key
    key_set = core::length(core::regexall("^.+$", local.key_arn)) > 0
    # AWS managed key aliases (alias/aws/...) are not customer managed keys
    is_aws_managed = core::length(core::regexall("alias/aws/", local.key_arn)) > 0
    is_compliant   = local.key_set && !local.is_aws_managed
  }

  enforce {
    condition     = local.is_compliant
    error_message = "Attribute 'kms_key_arn' must be set to a customer managed KMS key for 'aws_bedrockagentcore_gateway' resources."
  }
}
