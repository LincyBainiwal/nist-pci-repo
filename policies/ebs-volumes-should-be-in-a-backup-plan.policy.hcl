# Copyright IBM Corp. 2026

# EBS volumes should be covered by a backup plan

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.68.0, < 7.0.0"
    }
  }
}

locals {
  # Every aws_backup_selection in the plan (independent of the volume under evaluation).
  all_backup_selections = core::getresources("aws_backup_selection", {})
  # One list of resource ARNs per selection (null/absent -> empty list).
  selection_resource_lists = [
    for s in local.all_backup_selections :
    core::try(s.resources, null) != null ? s.resources : []
  ]
}

resource_policy "aws_ebs_volume" "ebs_volumes_should_be_in_a_backup_plan" {
  locals {
    volume_arn_raw = core::try(attrs.arn, null)
    volume_arn     = local.volume_arn_raw != null ? local.volume_arn_raw : ""
    covering       = [for l in local.selection_resource_lists : l if core::contains(l, local.volume_arn)]
    is_in_backup   = local.volume_arn != "" && core::length(local.covering) > 0
  }

  enforcement_level = "advisory"
  enforce {
    condition     = local.is_in_backup
    error_message = "EBS volumes should be included in AWS Backup plans. Reference the volume ARN in the 'resources' argument of an aws_backup_selection."
  }
}


