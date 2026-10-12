# Copyright IBM Corp. 2026

policytest {
  targets = [
    "multi-region-cloudtrail-enabled.policy.hcl"
  ]
}
# Test 1: Pass - Fully compliant CloudTrail trail
resource "aws_cloudtrail" "pass_fully_compliant_trail" {
  attrs = {
    name                          = "compliant-trail"
    s3_bucket_name               = "my-cloudtrail-bucket"
    is_multi_region_trail        = true
    enable_logging               = true
    include_global_service_events = true
    enable_log_file_validation   = true
    event_selector = [
      {
        include_management_events = true
        read_write_type          = "All"
      }
    ]
  }
}

# Test 2: Fail - Trail is not multi-region
resource "aws_cloudtrail" "fail_not_multi_region" {
  expect_failure = true
  attrs = {
    name                          = "single-region-trail"
    s3_bucket_name               = "my-cloudtrail-bucket"
    is_multi_region_trail        = false
    enable_logging               = true
    event_selector = [
      {
        include_management_events = true
        read_write_type          = "All"
      }
    ]
  }
}

# Test 3: Fail - Logging is disabled
resource "aws_cloudtrail" "fail_logging_disabled" {
  expect_failure = true
  attrs = {
    name                          = "logging-disabled-trail"
    s3_bucket_name               = "my-cloudtrail-bucket"
    is_multi_region_trail        = true
    enable_logging               = false
    event_selector = [
      {
        include_management_events = true
        read_write_type          = "All"
      }
    ]
  }
}

# Test 4: Pass - No event selector uses CloudTrail default management event behavior
resource "aws_cloudtrail" "pass_no_event_selector" {
  attrs = {
    name                          = "no-event-selector-trail"
    s3_bucket_name               = "my-cloudtrail-bucket"
    is_multi_region_trail        = true
    enable_logging               = true
  }
}

# Test 5: Pass - Empty event selector also falls back to default management event behavior
resource "aws_cloudtrail" "pass_empty_event_selector" {
  attrs = {
    name                          = "empty-event-selector-trail"
    s3_bucket_name               = "my-cloudtrail-bucket"
    is_multi_region_trail        = true
    enable_logging               = true
    event_selector               = []
  }
}

# Test 6: Fail - Management events disabled
resource "aws_cloudtrail" "fail_management_events_disabled" {
  expect_failure = true
  attrs = {
    name                          = "mgmt-events-disabled-trail"
    s3_bucket_name               = "my-cloudtrail-bucket"
    is_multi_region_trail        = true
    enable_logging               = true
    event_selector = [
      {
        include_management_events = false
        read_write_type          = "All"
      }
    ]
  }
}

# Test 7: Fail - Read-only events (not All)
resource "aws_cloudtrail" "fail_read_only_events" {
  expect_failure = true
  attrs = {
    name                          = "read-only-trail"
    s3_bucket_name               = "my-cloudtrail-bucket"
    is_multi_region_trail        = true
    enable_logging               = true
    event_selector = [
      {
        include_management_events = true
        read_write_type          = "ReadOnly"
      }
    ]
  }
}

# Test 8: Fail - Write-only events (not All)
resource "aws_cloudtrail" "fail_write_only_events" {
  expect_failure = true
  attrs = {
    name                          = "write-only-trail"
    s3_bucket_name               = "my-cloudtrail-bucket"
    is_multi_region_trail        = true
    enable_logging               = true
    event_selector = [
      {
        include_management_events = true
        read_write_type          = "WriteOnly"
      }
    ]
  }
}

# Test 9: Fail - Multiple violations (not multi-region and no event selector)
resource "aws_cloudtrail" "fail_multiple_violations" {
  expect_failure = true
  attrs = {
    name                          = "multiple-violations-trail"
    s3_bucket_name               = "my-cloudtrail-bucket"
    is_multi_region_trail        = false
    enable_logging               = true
  }
}

# Test 10: Pass - Trail with optional log file validation enabled
resource "aws_cloudtrail" "pass_with_log_validation" {
  attrs = {
    name                          = "validated-trail"
    s3_bucket_name               = "my-cloudtrail-bucket"
    is_multi_region_trail        = true
    enable_logging               = true
    enable_log_file_validation   = true
    event_selector = [
      {
        include_management_events = true
        read_write_type          = "All"
      }
    ]
  }
}
