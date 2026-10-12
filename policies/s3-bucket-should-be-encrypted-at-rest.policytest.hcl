# Copyright IBM Corp. 2026

policytest {
  targets = ["s3-bucket-should-be-encrypted-at-rest.policy.hcl"]
}

# PASS: aws:kms algorithm with explicit customer KMS key ARN
resource "aws_s3_bucket_server_side_encryption_configuration" "pass_kms_key" {
  attrs = {
    bucket = "pass_kms_key"
    rule = [{
      apply_server_side_encryption_by_default = [{
        sse_algorithm     = "aws:kms"
        kms_master_key_id = "arn:aws:kms:us-east-1:123456789012:key/abcd"
      }]
    }]
  }
}

# PASS: aws:kms:dsse algorithm with explicit customer KMS key ARN
resource "aws_s3_bucket_server_side_encryption_configuration" "pass_kms_dsse" {
  attrs = {
    bucket = "pass_kms_dsse"
    rule = [{
      apply_server_side_encryption_by_default = [{
        sse_algorithm     = "aws:kms:dsse"
        kms_master_key_id = "arn:aws:kms:us-east-1:123456789012:key/abcd"
      }]
    }]
  }
}

# FAIL: no rule block (empty list)
resource "aws_s3_bucket_server_side_encryption_configuration" "fail_no_rule" {
  expect_failure = true
  attrs = {
    bucket = "fail_no_rule"
    rule   = []
  }
}

# FAIL: rule block present but no apply_server_side_encryption_by_default
resource "aws_s3_bucket_server_side_encryption_configuration" "fail_no_apply_block" {
  expect_failure = true
  attrs = {
    bucket = "fail_no_apply_block"
    rule = [{
      bucket_key_enabled = true
    }]
  }
}

# FAIL: AES256 — not a KMS key
resource "aws_s3_bucket_server_side_encryption_configuration" "fail_aes256" {
  expect_failure = true
  attrs = {
    bucket = "fail_aes256"
    rule = [{
      apply_server_side_encryption_by_default = [{
        sse_algorithm = "AES256"
      }]
    }]
  }
}

# FAIL: sse_algorithm is empty string
resource "aws_s3_bucket_server_side_encryption_configuration" "fail_empty_sse_algorithm" {
  expect_failure = true
  attrs = {
    bucket = "fail_empty_sse_algorithm"
    rule = [{
      apply_server_side_encryption_by_default = [{
        sse_algorithm     = ""
        kms_master_key_id = "arn:aws:kms:us-east-1:123456789012:key/abcd"
      }]
    }]
  }
}

# FAIL: kms_master_key_id attribute absent
resource "aws_s3_bucket_server_side_encryption_configuration" "fail_kms_key_missing" {
  expect_failure = true
  attrs = {
    bucket = "fail_kms_key_missing"
    rule = [{
      apply_server_side_encryption_by_default = [{
        sse_algorithm = "aws:kms"
      }]
    }]
  }
}

# FAIL: kms_master_key_id is null
resource "aws_s3_bucket_server_side_encryption_configuration" "fail_kms_key_null" {
  expect_failure = true
  attrs = {
    bucket = "fail_kms_key_null"
    rule = [{
      apply_server_side_encryption_by_default = [{
        sse_algorithm     = "aws:kms"
        kms_master_key_id = null
      }]
    }]
  }
}

# FAIL: kms_master_key_id is empty string
resource "aws_s3_bucket_server_side_encryption_configuration" "fail_kms_key_empty" {
  expect_failure = true
  attrs = {
    bucket = "fail_kms_key_empty"
    rule = [{
      apply_server_side_encryption_by_default = [{
        sse_algorithm     = "aws:kms"
        kms_master_key_id = ""
      }]
    }]
  }
}

# FAIL: kms_master_key_id is the default AWS-managed S3 key alias
resource "aws_s3_bucket_server_side_encryption_configuration" "fail_kms_key_default_aws_s3" {
  expect_failure = true
  attrs = {
    bucket = "fail_kms_key_default_aws_s3"
    rule = [{
      apply_server_side_encryption_by_default = [{
        sse_algorithm     = "aws:kms"
        kms_master_key_id = "aws/s3"
      }]
    }]
  }
}
