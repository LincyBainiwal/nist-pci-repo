# Copyright IBM Corp. 2026

policytest {
  targets = ["cloudwatch-alarms-should-have-specified-actions-configured.policy.hcl"]
}

resource "aws_cloudwatch_metric_alarm" "pass_one_action" {
  attrs = {
    alarm_name    = "a1"
    alarm_actions = ["arn:aws:sns:us-east-1:123456789012:topic"]
  }
}

resource "aws_cloudwatch_metric_alarm" "pass_multiple_actions" {
  attrs = {
    alarm_name    = "a2"
    alarm_actions = ["arn:aws:sns:us-east-1:123456789012:t1", "arn:aws:sns:us-east-1:123456789012:t2"]
  }
}

resource "aws_cloudwatch_metric_alarm" "fail_missing_actions" {
  expect_failure = true
  attrs = {
    alarm_name = "a3"
  }
}

resource "aws_cloudwatch_metric_alarm" "fail_empty_actions" {
  expect_failure = true
  attrs = {
    alarm_name    = "a4"
    alarm_actions = []
  }
}

resource "aws_cloudwatch_metric_alarm" "fail_null_actions" {
  expect_failure = true
  attrs = {
    alarm_name    = "a5"
    alarm_actions = null
  }
}

resource "aws_cloudwatch_metric_alarm" "fail_only_ok_actions" {
  expect_failure = true
  attrs = {
    alarm_name                = "a6"
    ok_actions                = ["arn:aws:sns:us-east-1:123456789012:topic"]
    insufficient_data_actions = ["arn:aws:sns:us-east-1:123456789012:topic"]
  }
}

resource "aws_cloudwatch_composite_alarm" "pass_one_action" {
  attrs = {
    alarm_name    = "c1"
    alarm_rule    = "ALARM(a1)"
    alarm_actions = ["arn:aws:sns:us-east-1:123456789012:topic"]
  }
}

resource "aws_cloudwatch_composite_alarm" "fail_missing_actions" {
  expect_failure = true
  attrs = {
    alarm_name = "c2"
    alarm_rule = "ALARM(a1)"
  }
}

resource "aws_cloudwatch_composite_alarm" "fail_empty_actions" {
  expect_failure = true
  attrs = {
    alarm_name    = "c3"
    alarm_rule    = "ALARM(a1)"
    alarm_actions = []
  }
}

resource "aws_cloudwatch_composite_alarm" "fail_null_actions" {
  expect_failure = true
  attrs = {
    alarm_name    = "c4"
    alarm_rule    = "ALARM(a1)"
    alarm_actions = null
  }
}

