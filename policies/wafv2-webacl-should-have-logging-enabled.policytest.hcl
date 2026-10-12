# Copyright IBM Corp. 2026

policytest {
  targets = ["wafv2-webacl-should-have-logging-enabled.policy.hcl"]
}

# PASS: web ACL referenced by a logging configuration
resource "aws_wafv2_web_acl" "pass_with_logging" {
  attrs = {
    name  = "logged-acl"
    scope = "REGIONAL"
    arn   = "arn:aws:wafv2:us-east-1:123456789012:regional/webacl/logged-acl/11111111-1111-1111-1111-111111111111"
  }
}

# Companion logging configuration (lookup only)
resource "aws_wafv2_web_acl_logging_configuration" "logging_for_logged_acl" {
  attrs = {
    resource_arn            = "arn:aws:wafv2:us-east-1:123456789012:regional/webacl/logged-acl/11111111-1111-1111-1111-111111111111"
    log_destination_configs = ["arn:aws:logs:us-east-1:123456789012:log-group:aws-waf-logs-test"]
  }
}

# Logging configuration for a different web ACL (does not cover the ACLs below)
resource "aws_wafv2_web_acl_logging_configuration" "logging_for_other_acl" {
  attrs = {
    resource_arn            = "arn:aws:wafv2:us-east-1:123456789012:regional/webacl/other-acl/99999999-9999-9999-9999-999999999999"
    log_destination_configs = ["arn:aws:logs:us-east-1:123456789012:log-group:aws-waf-logs-other"]
  }
}

# FAIL: no logging configuration targets this web ACL (only a different ACL's config exists)
resource "aws_wafv2_web_acl" "fail_without_logging" {
  expect_failure = true
  attrs = {
    name  = "unlogged-acl"
    scope = "REGIONAL"
    arn   = "arn:aws:wafv2:us-east-1:123456789012:regional/webacl/unlogged-acl/22222222-2222-2222-2222-222222222222"
  }
}

# FAIL: CLOUDFRONT scoped web ACL without logging configuration
resource "aws_wafv2_web_acl" "fail_cloudfront_without_logging" {
  expect_failure = true
  attrs = {
    name  = "cf-unlogged-acl"
    scope = "CLOUDFRONT"
    arn   = "arn:aws:wafv2:us-east-1:123456789012:global/webacl/cf-unlogged-acl/33333333-3333-3333-3333-333333333333"
  }
}

# FAIL (missing attribute): arn omitted, so no logging configuration can be matched
resource "aws_wafv2_web_acl" "fail_missing_arn" {
  expect_failure = true
  attrs = {
    name  = "no-arn-acl"
    scope = "REGIONAL"
  }
}

# FAIL (null attribute): arn explicitly null; policy treats null as no match
resource "aws_wafv2_web_acl" "fail_null_arn" {
  expect_failure = true
  attrs = {
    name  = "null-arn-acl"
    scope = "REGIONAL"
    arn   = null
  }
}


