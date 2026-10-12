# Copyright IBM Corp. 2026

# multi-region-cloudtrail-enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

input "multi-region-cloudtrail-enabled-enforcement-level" {
  type = string
  default = "advisory"
}

input "s3BucketName" {
    type = string
    default = ""
}

input "snsTopicArn" {
    type = string
    default = ""
}

input "cloudWatchLogsLogGroupArn" {
    type = string
    default = ""
}

input "includeManagementEvents" {
    type = bool
    default = true
}

input "readWriteType" {
    type = string
    default = "ALL"
}

resource_policy "aws_cloudtrail" "multi_region_trail_required" {
    enforcement_level = input.multi-region-cloudtrail-enabled-enforcement-level
    filter = core::try(attrs.s3_bucket_name, "") != ""

    locals {
        trail_name = core::try(attrs.name, "unknown")
        is_multi_region = core::try(attrs.is_multi_region_trail, false)
        logging_enabled = core::try(attrs.enable_logging, true)
        configured_s3_bucket_name = core::try(attrs.s3_bucket_name, "")
        configured_sns_topic_name = core::try(attrs.sns_topic_name, "")
        configured_log_group_arn = core::try(attrs.cloud_watch_logs_group_arn, "")
        configured_log_group_arn_base = core::length(core::split(":*", local.configured_log_group_arn)) > 0 ? core::split(":*", local.configured_log_group_arn)[0] : local.configured_log_group_arn

        has_s3_bucket_name_input = input.s3BucketName != ""
        has_sns_topic_arn_input = input.snsTopicArn != ""
        has_log_group_arn_input = input.cloudWatchLogsLogGroupArn != ""

        sns_topic_arn_parts = local.has_sns_topic_arn_input ? core::split(":", input.snsTopicArn) : []
        target_sns_topic_name = core::length(local.sns_topic_arn_parts) > 0 ? local.sns_topic_arn_parts[core::length(local.sns_topic_arn_parts) - 1] : ""
        input_log_group_arn_base = core::length(core::split(":*", input.cloudWatchLogsLogGroupArn)) > 0 ? core::split(":*", input.cloudWatchLogsLogGroupArn)[0] : input.cloudWatchLogsLogGroupArn

        matches_s3_bucket_name = !local.has_s3_bucket_name_input || local.configured_s3_bucket_name == input.s3BucketName
        matches_sns_topic = !local.has_sns_topic_arn_input || local.configured_sns_topic_name == local.target_sns_topic_name
        matches_log_group = !local.has_log_group_arn_input || local.configured_log_group_arn_base == local.input_log_group_arn_base

        valid_read_write_type_input = core::contains(["ReadOnly", "WriteOnly", "ALL"], input.readWriteType)
        target_read_write_type = input.readWriteType == "ALL" ? "All" : input.readWriteType

        event_selector_value = core::try(attrs.event_selector, [])
        event_selectors_list = core::try([for s in local.event_selector_value : s], [])
        has_custom_event_selector = core::length(local.event_selectors_list) > 0
        matching_event_selectors = [
            for selector in local.event_selectors_list : selector
            if core::try(selector.include_management_events, true) == input.includeManagementEvents && core::try(selector.read_write_type, "All") == local.target_read_write_type
        ]
        default_event_behavior_matches = input.includeManagementEvents == true && local.target_read_write_type == "All"
        matches_event_selector_configuration = local.has_custom_event_selector ? core::length(local.matching_event_selectors) > 0 : local.default_event_behavior_matches
    }

    enforce {
        condition = local.valid_read_write_type_input
        error_message = "input.readWriteType must be one of 'ReadOnly', 'WriteOnly', or 'ALL'. Current value: '${input.readWriteType}'."
    }

    enforce {
        condition = local.is_multi_region == true
        error_message = "CloudTrail trail '${local.trail_name}' must be configured as a multi-region trail. Set 'is_multi_region_trail = true' to capture events across all AWS regions"
    }

    enforce {
        condition = local.logging_enabled == true
        error_message = "CloudTrail trail '${local.trail_name}' must have logging enabled. Set 'enable_logging = true' to record AWS API calls"
    }

    enforce {
        condition = local.matches_s3_bucket_name
        error_message = "CloudTrail trail '${local.trail_name}' must deliver log files to S3 bucket '${input.s3BucketName}' when input.s3BucketName is provided. Current bucket: '${local.configured_s3_bucket_name}'."
    }

    enforce {
        condition = local.matches_sns_topic
        error_message = "CloudTrail trail '${local.trail_name}' must use SNS topic '${local.target_sns_topic_name}' when input.snsTopicArn is provided. Current topic: '${local.configured_sns_topic_name}'."
    }

    enforce {
        condition = local.matches_log_group
        error_message = "CloudTrail trail '${local.trail_name}' must use CloudWatch Logs log group ARN '${input.cloudWatchLogsLogGroupArn}' when input.cloudWatchLogsLogGroupArn is provided. Current log group ARN: '${local.configured_log_group_arn}'."
    }

    enforce {
        condition = local.matches_event_selector_configuration
        error_message = "CloudTrail trail '${local.trail_name}' must match includeManagementEvents='${input.includeManagementEvents}' and readWriteType='${input.readWriteType}'. Trails without a custom event_selector use the default CloudTrail behavior of includeManagementEvents='true' and readWriteType='ALL'."
    }
}
