# Copyright IBM Corp. 2026

policytest {
  targets = ["cloudwatch-log-groups-should-be-retained-for-a-specified-time-period.policy.hcl"]
}

resource "aws_cloudwatch_log_group" "pass_365" {
  attrs = {
    name              = "pass-365"
    retention_in_days = 365
  }
}

resource "aws_cloudwatch_log_group" "pass_731" {
  attrs = {
    name              = "pass-731"
    retention_in_days = 731
  }
}

resource "aws_cloudwatch_log_group" "pass_never_expire" {
  attrs = {
    name              = "pass-never-expire"
    retention_in_days = 0
  }
}

resource "aws_cloudwatch_log_group" "fail_364" {
  expect_failure = true
  attrs = {
    name              = "fail-364"
    retention_in_days = 364
  }
}

resource "aws_cloudwatch_log_group" "fail_30" {
  expect_failure = true
  attrs = {
    name              = "fail-30"
    retention_in_days = 30
  }
}

resource "aws_cloudwatch_log_group" "fail_1" {
  expect_failure = true
  attrs = {
    name              = "fail-1"
    retention_in_days = 1
  }
}

resource "aws_cloudwatch_log_group" "fail_missing_retention" {
  expect_failure = true
  attrs = {
    name = "fail-missing"
  }
}

resource "aws_cloudwatch_log_group" "fail_null_retention" {
  expect_failure = true
  attrs = {
    name              = "fail-null"
    retention_in_days = null
  }
}


