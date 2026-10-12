# Copyright IBM Corp. 2026

#  S3 general purpose buckets should be encrypted at rest with AWS KMS keys

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.68.0, < 7.0.0"
    }
  }
}

input "s3-bucket-should-be-encrypted-at-rest-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket_should_be_encrypted_at_rest" {
  enforcement_level = input.s3-bucket-should-be-encrypted-at-rest-enforcement-level
  locals {
    rules       = core::try(attrs.rule, null) != null ? attrs.rule : []
    rule        = core::length(local.rules) > 0 ? [for r in local.rules : r][0] : null
    apply_raw   = local.rule != null ? core::try(local.rule.apply_server_side_encryption_by_default, null) : null
    apply_list  = local.apply_raw != null ? local.apply_raw : []
    apply_block = core::length(local.apply_list) > 0 ? [for a in local.apply_list : a][0] : null

    sse_algorithm = local.apply_block != null ? core::try(local.apply_block.sse_algorithm, null) : null
    kms_key_id    = local.apply_block != null ? core::try(local.apply_block.kms_master_key_id, null) : null

    is_compliant = (
      local.sse_algorithm != null
      && local.sse_algorithm != ""
      && local.sse_algorithm != "AES256"
      && local.kms_key_id != null
      && local.kms_key_id != ""
      && local.kms_key_id != "aws/s3"
    )
  }

  enforce {
    condition     = local.is_compliant
    error_message = "S3 Buckets should have encryption enabled at rest with AWS KMS Key"
  }
}
