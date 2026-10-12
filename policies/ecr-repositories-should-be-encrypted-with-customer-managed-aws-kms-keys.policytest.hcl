# Copyright IBM Corp. 2026

policytest {
  targets = ["ecr-repositories-should-be-encrypted-with-customer-managed-aws-kms-keys.policy.hcl"]
}

resource "aws_ecr_repository" "pass_kms_with_key" {
  attrs = {
    name = "pass"
    encryption_configuration = [{
      encryption_type = "KMS"
      kms_key         = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    }]
  }
}

resource "aws_ecr_repository" "fail_missing_block" {
  expect_failure = true
  attrs = {
    name = "no-block"
  }
}

resource "aws_ecr_repository" "fail_null_block" {
  expect_failure = true
  attrs = {
    name                     = "null-block"
    encryption_configuration = null
  }
}

resource "aws_ecr_repository" "fail_empty_block" {
  expect_failure = true
  attrs = {
    name                     = "empty-block"
    encryption_configuration = []
  }
}

resource "aws_ecr_repository" "fail_aes256" {
  expect_failure = true
  attrs = {
    name = "aes"
    encryption_configuration = [{
      encryption_type = "AES256"
      kms_key         = null
    }]
  }
}

resource "aws_ecr_repository" "fail_kms_missing_key" {
  expect_failure = true
  attrs = {
    name = "kms-no-key"
    encryption_configuration = [{
      encryption_type = "KMS"
    }]
  }
}

resource "aws_ecr_repository" "fail_kms_null_key" {
  expect_failure = true
  attrs = {
    name = "kms-null-key"
    encryption_configuration = [{
      encryption_type = "KMS"
      kms_key         = null
    }]
  }
}

resource "aws_ecr_repository" "fail_kms_empty_key" {
  expect_failure = true
  attrs = {
    name = "kms-empty-key"
    encryption_configuration = [{
      encryption_type = "KMS"
      kms_key         = ""
    }]
  }
}

resource "aws_ecr_repository" "fail_missing_type" {
  expect_failure = true
  attrs = {
    name = "no-type"
    encryption_configuration = [{
      kms_key = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    }]
  }
}

resource "aws_ecr_repository" "fail_null_type" {
  expect_failure = true
  attrs = {
    name = "null-type"
    encryption_configuration = [{
      encryption_type = null
      kms_key         = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    }]
  }
}


