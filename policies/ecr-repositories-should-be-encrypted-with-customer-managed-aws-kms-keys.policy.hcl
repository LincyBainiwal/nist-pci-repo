# Copyright IBM Corp. 2026

# ECR repositories should be encrypted with customer managed AWS KMS keys

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.68.0, < 7.0.0"
    }
  }
}

resource_policy "aws_ecr_repository" "encrypted_with_customer_managed_kms_key" {
  locals {
    enc_raw         = core::try(attrs.encryption_configuration, null)
    enc_list        = local.enc_raw != null ? local.enc_raw : []
    has_enc         = core::length(local.enc_list) > 0
    enc_type_raw    = local.has_enc ? core::try(local.enc_list[0].encryption_type, null) : null
    kms_key_raw     = local.has_enc ? core::try(local.enc_list[0].kms_key, null) : null
    is_kms          = local.enc_type_raw != null && local.enc_type_raw == "KMS"
    has_kms_key     = local.kms_key_raw != null && local.kms_key_raw != ""
    is_compliant    = local.has_enc && local.is_kms && local.has_kms_key
  }

  enforcement_level = "advisory"
  enforce {
    condition     = local.is_compliant
    error_message = "ECR repositories must be encrypted with customer-managed KMS keys."
  }
}


