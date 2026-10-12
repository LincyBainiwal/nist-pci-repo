# Copyright IBM Corp. 2026

policytest {
  targets = ["application-load-balancers-should-be-associated-with-an-aws-waf-web-acl.policy.hcl"]
}

# PASS: constant ALB ARN
resource "aws_wafv2_web_acl_association" "pass_constant_alb_arn" {
  attrs = {
    resource_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-alb/50dc6c495c0c9188"
    web_acl_arn  = "arn:aws:wafv2:us-east-1:123456789012:regional/webacl/test/abc"
  }
}

# PASS: ARN resolved from an aws_lb reference
resource "aws_wafv2_web_acl_association" "pass_lb_reference_arn" {
  attrs = {
    resource_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/ref-alb/1234567890abcdef"
    web_acl_arn  = "arn:aws:wafv2:us-east-1:123456789012:regional/webacl/test/abc"
  }
}

# FAIL: resource_arn omitted
resource "aws_wafv2_web_acl_association" "fail_missing_resource_arn" {
  expect_failure = true
  attrs = {
    web_acl_arn = "arn:aws:wafv2:us-east-1:123456789012:regional/webacl/test/abc"
  }
}

# FAIL: resource_arn explicitly null (policy treats null as not configured)
resource "aws_wafv2_web_acl_association" "fail_null_resource_arn" {
  expect_failure = true
  attrs = {
    resource_arn = null
    web_acl_arn  = "arn:aws:wafv2:us-east-1:123456789012:regional/webacl/test/abc"
  }
}

# FAIL: resource_arn empty string
resource "aws_wafv2_web_acl_association" "fail_empty_resource_arn" {
  expect_failure = true
  attrs = {
    resource_arn = ""
    web_acl_arn  = "arn:aws:wafv2:us-east-1:123456789012:regional/webacl/test/abc"
  }
}


