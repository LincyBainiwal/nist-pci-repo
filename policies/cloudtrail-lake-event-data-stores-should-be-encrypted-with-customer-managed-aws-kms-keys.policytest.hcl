# Copyright IBM Corp. 2026

policytest {
  targets = ["cloudtrail-lake-event-data-stores-should-be-encrypted-with-customer-managed-aws-kms-keys.policy.hcl"]
}

resource "aws_cloudtrail_event_data_store" "pass_kms_arn" {
  attrs = {
    name       = "eds-arn"
    kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  }
}

resource "aws_cloudtrail_event_data_store" "pass_kms_key_id" {
  attrs = {
    name       = "eds-id"
    kms_key_id = "12345678-1234-1234-1234-123456789012"
  }
}

resource "aws_cloudtrail_event_data_store" "pass_kms_alias" {
  attrs = {
    name       = "eds-alias"
    kms_key_id = "alias/my-key"
  }
}

# kms_key_id attribute omitted entirely
resource "aws_cloudtrail_event_data_store" "fail_missing_kms" {
  expect_failure = true
  attrs = {
    name = "eds-missing"
  }
}

resource "aws_cloudtrail_event_data_store" "fail_null_kms" {
  expect_failure = true
  attrs = {
    name       = "eds-null"
    kms_key_id = null
  }
}

resource "aws_cloudtrail_event_data_store" "fail_empty_kms" {
  expect_failure = true
  attrs = {
    name       = "eds-empty"
    kms_key_id = ""
  }
}


