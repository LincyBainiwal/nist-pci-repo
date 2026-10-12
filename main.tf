# -----------------------------------------------------------------------------
# NIST / PCI policy testing fixture
#
# PLAN ONLY - NEVER APPLY. All ARNs, account IDs and subnet IDs below are fake.
#
# Every policy in ./policies gets resources named pass_* (should be compliant)
# and fail_* (should violate the policy), so the evaluation result for each
# resource can be checked against its name.
#
# Phase 1: local   -> terraform plan (credentials come from the environment)
# Phase 2: HCP     -> uncomment the cloud block below and attach ./policies
# -----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.68.0, < 7.0.0"
    }
  }

  # Phase 2 (HCP Terraform): uncomment and fill in.
  cloud {
    organization = "nagateja-test-org"
    workspaces {
      name = "nist-pci-policies-testing"
      project = "Lincy Project"
    }
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}

# Credentials are read from the environment (AWS_ACCESS_KEY_ID etc.), never
# hardcoded. The skip_* flags let `terraform plan` run without calling AWS
# for account lookups, since nothing here is ever applied.
provider "aws" {
  region                      = var.region
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}

locals {
  prefix     = "nistpci"
  account_id = "123456789012"

  kms_key_arn = "arn:aws:kms:us-east-1:${local.account_id}:key/11111111-2222-3333-4444-555555555555"
  # AWS managed key alias - NOT a customer managed key.
  aws_managed_key_arn = "arn:aws:kms:us-east-1:${local.account_id}:alias/aws/bedrock"
  sns_topic_arn       = "arn:aws:sns:us-east-1:${local.account_id}:${local.prefix}-alerts"
  role_arn            = "arn:aws:iam::${local.account_id}:role/${local.prefix}-role"
  fake_subnets        = ["subnet-0aaaaaaaaaaaaaaa1", "subnet-0bbbbbbbbbbbbbbb2"]

  container_definitions = jsonencode([{
    name      = "app"
    image     = "public.ecr.aws/nginx/nginx:latest"
    essential = true
    memory    = 128
  }])
}

# =============================================================================
# 1. application-load-balancers-should-be-associated-with-an-aws-waf-web-acl
#    Resource: aws_wafv2_web_acl_association (resource_arn must be set)
#    resource_arn is a required argument, so a null/empty "fail" case cannot be
#    expressed in valid Terraform; only the pass paths are covered here.
# =============================================================================
resource "aws_lb" "pass_waf_assoc" {
  name               = "${local.prefix}-alb"
  load_balancer_type = "application"
  internal           = true
  subnets            = local.fake_subnets
}

# #arn is "known after apply" at plan time - exercises the unknown-value path.
resource "aws_wafv2_web_acl_association" "pass_unknown_alb_arn" {
  resource_arn = aws_lb.pass_waf_assoc.arn
  web_acl_arn  = aws_wafv2_web_acl.pass_logging.arn
}

# #arn is known at plan time.
resource "aws_wafv2_web_acl_association" "pass_known_alb_arn" {
  resource_arn = "arn:aws:elasticloadbalancing:us-east-1:${local.account_id}:loadbalancer/app/${local.prefix}-known/50dc6c495c0c9188"
  web_acl_arn  = aws_wafv2_web_acl.pass_logging.arn
}

# =============================================================================
# 2. cloudtrail-lake-event-data-stores-should-be-encrypted-with-customer-managed-aws-kms-keys
#    Resource: aws_cloudtrail_event_data_store (kms_key_id must be set)
# =============================================================================
# resource "aws_cloudtrail_event_data_store" "pass_kms" {
#   name       = "${local.prefix}-eds-pass-kms"
#   kms_key_id = local.kms_key_arn
# }

# resource "aws_cloudtrail_event_data_store" "fail_no_kms" {
#   name = "${local.prefix}-eds-fail-no-kms"
# }

# =============================================================================
# 3 + 4. cloudwatch-alarm-actions-should-be-enabled      (actions_enabled == true)
#        cloudwatch-alarms-should-have-specified-actions-configured (alarm_actions non-empty)
#
#   case                      actions_enabled  alarm_actions   policy 3   policy 4
#   pass_all_configured       default (true)   set             pass       pass
#   fail_actions_disabled     false            set             FAIL       pass
#   fail_no_alarm_actions     default (true)   unset           pass       FAIL
# =============================================================================
# locals {
#   alarm_cases = {
#     pass_all_configured   = { actions_enabled = null, alarm_actions = [local.sns_topic_arn] }
#     fail_actions_disabled = { actions_enabled = false, alarm_actions = [local.sns_topic_arn] }
#     fail_no_alarm_actions = { actions_enabled = null, alarm_actions = null }
#   }
# }

# resource "aws_cloudwatch_metric_alarm" "case" {
#   for_each = local.alarm_cases

#   alarm_name          = "${local.prefix}-${each.key}"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 1
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/EC2"
#   period              = 300
#   statistic           = "Average"
#   threshold           = 80

#   actions_enabled = each.value.actions_enabled
#   alarm_actions   = each.value.alarm_actions
# }

# resource "aws_cloudwatch_composite_alarm" "case" {
#   for_each = local.alarm_cases

#   alarm_name = "${local.prefix}-composite-${each.key}"
#   alarm_rule = "ALARM(\"${local.prefix}-${each.key}\")"

#   actions_enabled = each.value.actions_enabled
#   alarm_actions   = each.value.alarm_actions
# }

# =============================================================================
# 5. cloudwatch-log-groups-should-be-retained-for-a-specified-time-period
#    Resource: aws_cloudwatch_log_group (retention_in_days == 0 or >= 365)
#    The "retention not set" case is left out on purpose: the provider may plan
#    a default for it, so it would not test the policy's null branch reliably.
# =============================================================================
# locals {
#   log_group_retention = {
#     pass_365_days        = 365
#     pass_never_expire    = 0
#     fail_30_days         = 30
#     fail_364_days_almost = 365 - 1 # 364 is not a valid AWS value; see note below
#   }
# }

# NOTE: the provider only accepts specific retention values, so 364 is rejected
# at validate time. It is kept out of the real resource set below.
# resource "aws_cloudwatch_log_group" "case" {
#   for_each = { for k, v in local.log_group_retention : k => v if k != "fail_364_days_almost" }

#   name              = "/${local.prefix}/${each.key}"
#   retention_in_days = each.value
# }

# =============================================================================
# 6. ebs-volumes-should-be-in-a-backup-plan
#    Resource: aws_ebs_volume (volume arn must appear in an aws_backup_selection)
#    NOTE: aws_ebs_volume.arn is "known after apply", so at plan time the
#    policy compares an unknown value. Check how the engine reports pass_/fail_.
# =============================================================================
# resource "aws_ebs_volume" "pass_in_backup" {
#   availability_zone = "${var.region}a"
#   size              = 1
# }

# resource "aws_ebs_volume" "fail_not_in_backup" {
#   availability_zone = "${var.region}a"
#   size              = 1
# }

# resource "aws_backup_vault" "this" {
#   name = "${local.prefix}-vault"
# }

# resource "aws_backup_plan" "this" {
#   name = "${local.prefix}-plan"

#   rule {
#     rule_name         = "daily"
#     target_vault_name = aws_backup_vault.this.name
#     schedule          = "cron(0 5 * * ? *)"
#   }
# }

# resource "aws_backup_selection" "this" {
#   name         = "${local.prefix}-selection"
#   plan_id      = aws_backup_plan.this.id
#   iam_role_arn = local.role_arn

#   # Only the "pass" volume is covered.
#   resources = [aws_ebs_volume.pass_in_backup.arn]
# }

# =============================================================================
# 7. ecr-repositories-should-be-encrypted-with-customer-managed-aws-kms-keys
#    Resource: aws_ecr_repository (encryption_type KMS + kms_key set)
# =============================================================================
# resource "aws_ecr_repository" "pass_cmk" {
#   name = "${local.prefix}/pass-cmk"

#   encryption_configuration {
#     encryption_type = "KMS"
#     kms_key         = local.kms_key_arn
#   }
# }

# resource "aws_ecr_repository" "fail_aes256" {
#   name = "${local.prefix}/fail-aes256"

#   encryption_configuration {
#     encryption_type = "AES256"
#   }
# }

# KMS with no kms_key -> uses the AWS managed aws/ecr key, not a CMK.
# resource "aws_ecr_repository" "fail_kms_no_key" {
#   name = "${local.prefix}/fail-kms-no-key"

#   encryption_configuration {
#     encryption_type = "KMS"
#   }
# }

# resource "aws_ecr_repository" "fail_no_encryption_block" {
#   name = "${local.prefix}/fail-no-encryption-block"
# }

# =============================================================================
# 8. ecs-task-definitions-should-not-use-host-network-mode
#    Resource: aws_ecs_task_definition (network_mode != "host")
# =============================================================================
# resource "aws_ecs_task_definition" "pass_awsvpc" {
#   family                = "${local.prefix}-pass-awsvpc"
#   network_mode          = "awsvpc"
#   container_definitions = local.container_definitions
# }

# resource "aws_ecs_task_definition" "pass_bridge" {
#   family                = "${local.prefix}-pass-bridge"
#   network_mode          = "bridge"
#   container_definitions = local.container_definitions
# }

# resource "aws_ecs_task_definition" "pass_unset" {
#   family                = "${local.prefix}-pass-unset"
#   container_definitions = local.container_definitions
# }

# resource "aws_ecs_task_definition" "fail_host" {
#   family                = "${local.prefix}-fail-host"
#   network_mode          = "host"
#   container_definitions = local.container_definitions
# }

# =============================================================================
# 9. wafv2-webacl-should-have-logging-enabled
#    Resource: aws_wafv2_web_acl (needs a matching logging configuration)
#    NOTE: web ACL arn is "known after apply" at plan time (same caveat as EBS).
# =============================================================================
# resource "aws_wafv2_web_acl" "pass_logging" {
#   name  = "${local.prefix}-pass-logging"
#   scope = "REGIONAL"

#   default_action {
#     allow {}
#   }

#   visibility_config {
#     cloudwatch_metrics_enabled = false
#     metric_name                = "${local.prefix}-pass-logging"
#     sampled_requests_enabled   = false
#   }
# }

# resource "aws_cloudwatch_log_group" "waf_logs" {
#   # WAF requires the aws-waf-logs- prefix.
#   name              = "aws-waf-logs-${local.prefix}"
#   retention_in_days = 365
# }

# resource "aws_wafv2_web_acl_logging_configuration" "pass_logging" {
#   resource_arn            = aws_wafv2_web_acl.pass_logging.arn
#   log_destination_configs = [aws_cloudwatch_log_group.waf_logs.arn]
# }

# resource "aws_wafv2_web_acl" "fail_no_logging" {
#   name  = "${local.prefix}-fail-no-logging"
#   scope = "REGIONAL"

#   default_action {
#     allow {}
#   }

#   visibility_config {
#     cloudwatch_metrics_enabled = false
#     metric_name                = "${local.prefix}-fail-no-logging"
#     sampled_requests_enabled   = false
#   }
# }

# =============================================================================
# 10. s3-bucket-should-be-encrypted-at-rest
#     Resource: aws_s3_bucket_server_side_encryption_configuration
#     (sse_algorithm != AES256, kms_master_key_id set and != aws/s3)
# =============================================================================
# resource "aws_s3_bucket" "enc_pass" {
#   bucket = "${local.prefix}-enc-pass"
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "pass_kms" {
#   bucket = aws_s3_bucket.enc_pass.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm     = "aws:kms"
#       kms_master_key_id = local.kms_key_arn
#     }
#   }
# }

# resource "aws_s3_bucket" "enc_fail_aes256" {
#   bucket = "${local.prefix}-enc-fail-aes256"
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "fail_aes256" {
#   bucket = aws_s3_bucket.enc_fail_aes256.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

# resource "aws_s3_bucket" "enc_fail_kms_no_key" {
#   bucket = "${local.prefix}-enc-fail-kms-no-key"
# }

# # aws:kms without a key -> AWS managed aws/s3 key, not a CMK.
# resource "aws_s3_bucket_server_side_encryption_configuration" "fail_kms_no_key" {
#   bucket = aws_s3_bucket.enc_fail_kms_no_key.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "aws:kms"
#     }
#   }
# }

# =============================================================================
# 11. s3-bucket-should-have-object-lock-enabled
#     Resource: aws_s3_bucket_object_lock_configuration
#     (default_retention.mode in GOVERNANCE / COMPLIANCE)
#     The provider rejects invalid modes at validate time, so the only
#     non-compliant shape is "no default retention rule".
# =============================================================================
# resource "aws_s3_bucket" "lock_pass_compliance" {
#   bucket              = "${local.prefix}-lock-pass-compliance"
#   object_lock_enabled = true
# }

# resource "aws_s3_bucket_object_lock_configuration" "pass_compliance" {
#   bucket = aws_s3_bucket.lock_pass_compliance.id

#   rule {
#     default_retention {
#       mode = "COMPLIANCE"
#       days = 5
#     }
#   }
# }

# resource "aws_s3_bucket" "lock_pass_governance" {
#   bucket              = "${local.prefix}-lock-pass-governance"
#   object_lock_enabled = true
# }

# resource "aws_s3_bucket_object_lock_configuration" "pass_governance" {
#   bucket = aws_s3_bucket.lock_pass_governance.id

#   rule {
#     default_retention {
#       mode  = "GOVERNANCE"
#       years = 1
#     }
#   }
# }

# resource "aws_s3_bucket" "lock_fail_no_rule" {
#   bucket              = "${local.prefix}-lock-fail-no-rule"
#   object_lock_enabled = true
# }

# resource "aws_s3_bucket_object_lock_configuration" "fail_no_rule" {
#   bucket = aws_s3_bucket.lock_fail_no_rule.id
# }

# =============================================================================
# 12. cloudtrail-enabled
#     Resource: aws_cloudtrail (enable_logging must not be false)
# =============================================================================
# resource "aws_cloudtrail" "pass_logging_default" {
#   name           = "${local.prefix}-pass-default"
#   s3_bucket_name = aws_s3_bucket.enc_pass.id
# }

# resource "aws_cloudtrail" "pass_logging_true" {
#   name           = "${local.prefix}-pass-true"
#   s3_bucket_name = aws_s3_bucket.enc_pass.id
#   enable_logging = true
# }

# resource "aws_cloudtrail" "fail_logging_false" {
#   name           = "${local.prefix}-fail-false"
#   s3_bucket_name = aws_s3_bucket.enc_pass.id
#   enable_logging = false
# }

# =============================================================================
# 13. bedrockagentcore-gateway-encrypted-cmk
#     Resource: aws_bedrockagentcore_gateway (kms_key_arn set, not alias/aws/...)
# =============================================================================
# resource "aws_bedrockagentcore_gateway" "pass_cmk" {
#   name            = "${local.prefix}-gw-pass"
#   role_arn        = local.role_arn
#   protocol_type   = "MCP"
#   authorizer_type = "AWS_IAM"
#   kms_key_arn     = local.kms_key_arn
# }

# resource "aws_bedrockagentcore_gateway" "fail_no_key" {
#   name            = "${local.prefix}-gw-fail-no-key"
#   role_arn        = local.role_arn
#   protocol_type   = "MCP"
#   authorizer_type = "AWS_IAM"
# }

# resource "aws_bedrockagentcore_gateway" "fail_aws_managed_key" {
#   name            = "${local.prefix}-gw-fail-aws-key"
#   role_arn        = local.role_arn
#   protocol_type   = "MCP"
#   authorizer_type = "AWS_IAM"
#   kms_key_arn     = local.aws_managed_key_arn
# }

# =============================================================================
# 14. bedrockagentcore-memory-encrypted-cmk
#     Resource: aws_bedrockagentcore_memory (encryption_key_arn set, not alias/aws/...)
# =============================================================================
# resource "aws_bedrockagentcore_memory" "pass_cmk" {
#   name                  = "${local.prefix}_mem_pass"
#   event_expiry_duration = 30
#   encryption_key_arn    = local.kms_key_arn
# }

# resource "aws_bedrockagentcore_memory" "fail_no_key" {
#   name                  = "${local.prefix}_mem_fail_no_key"
#   event_expiry_duration = 30
# }

# resource "aws_bedrockagentcore_memory" "fail_aws_managed_key" {
#   name                  = "${local.prefix}_mem_fail_aws_key"
#   event_expiry_duration = 30
#   encryption_key_arn    = local.aws_managed_key_arn
# }
