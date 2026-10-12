# Copyright IBM Corp. 2026

policytest {
  targets = ["s3-bucket-should-have-object-lock-enabled.policy.hcl"]
}

# PASS: COMPLIANCE mode with days retention
resource "aws_s3_bucket_object_lock_configuration" "pass_compliance" {
  attrs = {
    bucket              = "bucket-compliance"
    object_lock_enabled = "Enabled"
    rule = [{
      default_retention = [{
        mode = "COMPLIANCE"
        days = 5
      }]
    }]
  }
}

# PASS: GOVERNANCE mode with years retention
resource "aws_s3_bucket_object_lock_configuration" "pass_governance" {
  attrs = {
    bucket = "bucket-governance"
    rule = [{
      default_retention = [{
        mode  = "GOVERNANCE"
        years = 1
      }]
    }]
  }
}

# FAIL: no rule block at all
resource "aws_s3_bucket_object_lock_configuration" "fail_no_rule" {
  expect_failure = true
  attrs = {
    bucket              = "bucket-no-rule"
    object_lock_enabled = "Enabled"
  }
}

# FAIL: empty default_retention list
resource "aws_s3_bucket_object_lock_configuration" "fail_empty_retention" {
  expect_failure = true
  attrs = {
    bucket = "bucket-empty-retention"
    rule = [{
      default_retention = []
    }]
  }
}

# FAIL: mode attribute missing from default_retention
resource "aws_s3_bucket_object_lock_configuration" "fail_missing_mode" {
  expect_failure = true
  attrs = {
    bucket = "bucket-no-mode"
    rule = [{
      default_retention = [{
        days = 3
      }]
    }]
  }
}

# FAIL: mode is explicitly null
resource "aws_s3_bucket_object_lock_configuration" "fail_null_mode" {
  expect_failure = true
  attrs = {
    bucket = "bucket-null-mode"
    rule = [{
      default_retention = [{
        mode = null
        days = 3
      }]
    }]
  }
}

# FAIL: invalid mode value
resource "aws_s3_bucket_object_lock_configuration" "fail_invalid_mode" {
  expect_failure = true
  attrs = {
    bucket = "bucket-invalid-mode"
    rule = [{
      default_retention = [{
        mode = "INVALID"
        days = 3
      }]
    }]
  }
}
