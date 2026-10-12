# Copyright IBM Corp. 2026

policytest {
  targets = ["bedrockagentcore-gateway-encrypted-cmk.policy.hcl"]
}

# ---- PASS cases ----

resource "aws_bedrockagentcore_gateway" "pass_key_arn" {
  attrs = {
    name            = "pass_key_arn"
    role_arn        = "arn:aws:iam::111122223333:role/gateway-role"
    authorizer_type = "AWS_IAM"
    protocol_type   = "MCP"
    kms_key_arn     = "arn:aws:kms:us-east-1:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"
  }
}

resource "aws_bedrockagentcore_gateway" "pass_customer_alias_arn" {
  attrs = {
    name            = "pass_customer_alias_arn"
    role_arn        = "arn:aws:iam::111122223333:role/gateway-role"
    authorizer_type = "AWS_IAM"
    protocol_type   = "MCP"
    kms_key_arn     = "arn:aws:kms:us-east-1:111122223333:alias/my-gateway-key"
  }
}

resource "aws_bedrockagentcore_gateway" "pass_other_region_key" {
  attrs = {
    name            = "pass_other_region_key"
    role_arn        = "arn:aws:iam::111122223333:role/gateway-role"
    authorizer_type = "AWS_IAM"
    protocol_type   = "MCP"
    kms_key_arn     = "arn:aws:kms:eu-west-1:111122223333:key/abcd1234-ab12-cd34-ef56-abcdef123456"
  }
}

resource "aws_bedrockagentcore_gateway" "pass_govcloud_partition_key" {
  attrs = {
    name            = "pass_govcloud_partition_key"
    role_arn        = "arn:aws:iam::111122223333:role/gateway-role"
    authorizer_type = "AWS_IAM"
    protocol_type   = "MCP"
    kms_key_arn     = "arn:aws-us-gov:kms:us-gov-west-1:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"
  }
}

# ---- FAIL cases ----

resource "aws_bedrockagentcore_gateway" "fail_key_missing" {
  expect_failure = true
  attrs = {
    name            = "fail_key_missing"
    role_arn        = "arn:aws:iam::111122223333:role/gateway-role"
    authorizer_type = "AWS_IAM"
    protocol_type   = "MCP"
  }
}

resource "aws_bedrockagentcore_gateway" "fail_key_null" {
  expect_failure = true
  attrs = {
    name            = "fail_key_null"
    role_arn        = "arn:aws:iam::111122223333:role/gateway-role"
    authorizer_type = "AWS_IAM"
    protocol_type   = "MCP"
    kms_key_arn     = null
  }
}

resource "aws_bedrockagentcore_gateway" "fail_key_empty_string" {
  expect_failure = true
  attrs = {
    name            = "fail_key_empty_string"
    role_arn        = "arn:aws:iam::111122223333:role/gateway-role"
    authorizer_type = "AWS_IAM"
    protocol_type   = "MCP"
    kms_key_arn     = ""
  }
}

resource "aws_bedrockagentcore_gateway" "fail_aws_managed_alias_arn" {
  expect_failure = true
  attrs = {
    name            = "fail_aws_managed_alias_arn"
    role_arn        = "arn:aws:iam::111122223333:role/gateway-role"
    authorizer_type = "AWS_IAM"
    protocol_type   = "MCP"
    kms_key_arn     = "arn:aws:kms:us-east-1:111122223333:alias/aws/bedrock"
  }
}

resource "aws_bedrockagentcore_gateway" "fail_aws_managed_alias_name" {
  expect_failure = true
  attrs = {
    name            = "fail_aws_managed_alias_name"
    role_arn        = "arn:aws:iam::111122223333:role/gateway-role"
    authorizer_type = "AWS_IAM"
    protocol_type   = "MCP"
    kms_key_arn     = "alias/aws/bedrock"
  }
}

resource "aws_bedrockagentcore_gateway" "fail_missing_key_jwt_authorizer" {
  expect_failure = true
  attrs = {
    name            = "fail_jwt"
    role_arn        = "arn:aws:iam::111122223333:role/gateway-role"
    authorizer_type = "CUSTOM_JWT"
    protocol_type   = "MCP"
    description     = "No CMK"
  }
}
