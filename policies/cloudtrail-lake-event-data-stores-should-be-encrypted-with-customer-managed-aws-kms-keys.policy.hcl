# Copyright IBM Corp. 2026

# CloudTrail Lake event data stores should be encrypted with customer managed AWS KMS keys

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.68.0, < 7.0.0"
    }
  }
}

resource_policy "aws_cloudtrail_event_data_store" "encrypted_with_kms_key" {
  locals {
    kms_key_id_raw = core::try(attrs.kms_key_id, null)
    kms_key_set    = local.kms_key_id_raw != null && local.kms_key_id_raw != ""
  }

  enforcement_level = "advisory"
  enforce {
    condition     = local.kms_key_set
    error_message = "CloudTrail Event Data Stores must be encrypted with a KMS key. Specify a valid KMS key ID in the 'kms_key_id' attribute."
  }
}


