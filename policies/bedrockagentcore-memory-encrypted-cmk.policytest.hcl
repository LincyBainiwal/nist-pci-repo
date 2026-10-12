# Copyright IBM Corp. 2026

policytest {
  targets = ["bedrockagentcore-memory-encrypted-cmk.policy.hcl"]
}

# ---- PASS cases ----

resource "aws_bedrockagentcore_memory" "pass_key_arn" {
  attrs = {
    name                  = "pass_key_arn"
    event_expiry_duration = 30
    encryption_key_arn    = "arn:aws:kms:us-east-1:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"
  }
}

resource "aws_bedrockagentcore_memory" "pass_customer_alias_arn" {
  attrs = {
    name                  = "pass_customer_alias_arn"
    event_expiry_duration = 30
    encryption_key_arn    = "arn:aws:kms:us-east-1:111122223333:alias/my-memory-key"
  }
}

resource "aws_bedrockagentcore_memory" "pass_other_region_key" {
  attrs = {
    name                  = "pass_other_region_key"
    event_expiry_duration = 365
    encryption_key_arn    = "arn:aws:kms:eu-west-1:111122223333:key/abcd1234-ab12-cd34-ef56-abcdef123456"
  }
}

resource "aws_bedrockagentcore_memory" "pass_govcloud_partition_key" {
  attrs = {
    name                  = "pass_govcloud_key"
    event_expiry_duration = 7
    encryption_key_arn    = "arn:aws-us-gov:kms:us-gov-west-1:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"
  }
}

resource "aws_bedrockagentcore_memory" "pass_fully_configured" {
  attrs = {
    name                      = "pass_full"
    description               = "Memory for support agent"
    event_expiry_duration     = 60
    encryption_key_arn        = "arn:aws:kms:us-east-1:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"
    memory_execution_role_arn = "arn:aws:iam::111122223333:role/memory-role"
    tags = {
      env = "prod"
    }
  }
}

# ---- FAIL cases ----

resource "aws_bedrockagentcore_memory" "fail_key_missing" {
  expect_failure = true
  attrs = {
    name                  = "fail_key_missing"
    event_expiry_duration = 30
  }
}

resource "aws_bedrockagentcore_memory" "fail_key_null" {
  expect_failure = true
  attrs = {
    name                  = "fail_key_null"
    event_expiry_duration = 30
    encryption_key_arn    = null
  }
}

resource "aws_bedrockagentcore_memory" "fail_key_empty_string" {
  expect_failure = true
  attrs = {
    name                  = "fail_key_empty"
    event_expiry_duration = 30
    encryption_key_arn    = ""
  }
}

resource "aws_bedrockagentcore_memory" "fail_aws_managed_alias_arn" {
  expect_failure = true
  attrs = {
    name                  = "fail_aws_managed_alias_arn"
    event_expiry_duration = 30
    encryption_key_arn    = "arn:aws:kms:us-east-1:111122223333:alias/aws/bedrock"
  }
}

resource "aws_bedrockagentcore_memory" "fail_aws_managed_alias_name" {
  expect_failure = true
  attrs = {
    name                  = "fail_aws_managed_alias_name"
    event_expiry_duration = 30
    encryption_key_arn    = "alias/aws/bedrock"
  }
}

resource "aws_bedrockagentcore_memory" "fail_missing_key_other_settings_ok" {
  expect_failure = true
  attrs = {
    name                      = "fail_other_ok"
    description               = "No CMK"
    event_expiry_duration     = 90
    memory_execution_role_arn = "arn:aws:iam::111122223333:role/memory-role"
  }
}
