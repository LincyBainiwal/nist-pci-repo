# Copyright IBM Corp. 2026

policytest {
  targets = ["cloudwatch-alarm-actions-should-be-enabled.policy.hcl"]
}

resource "aws_cloudwatch_metric_alarm" "metric_enabled" {
  attrs = {
    alarm_name          = "metric-enabled"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods  = 1
    actions_enabled     = true
  }
}

resource "aws_cloudwatch_metric_alarm" "metric_unset" {
  attrs = {
    alarm_name          = "metric-unset"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods  = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "metric_disabled" {
  expect_failure = true
  attrs = {
    alarm_name          = "metric-disabled"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods  = 1
    actions_enabled     = false
  }
}

resource "aws_cloudwatch_composite_alarm" "composite_enabled" {
  attrs = {
    alarm_name      = "composite-enabled"
    alarm_rule      = "ALARM(metric-enabled)"
    actions_enabled = true
  }
}

resource "aws_cloudwatch_composite_alarm" "composite_unset" {
  attrs = {
    alarm_name = "composite-unset"
    alarm_rule = "ALARM(metric-enabled)"
  }
}

resource "aws_cloudwatch_composite_alarm" "composite_disabled" {
  expect_failure = true
  attrs = {
    alarm_name      = "composite-disabled"
    alarm_rule      = "ALARM(metric-enabled)"
    actions_enabled = false
  }
}


