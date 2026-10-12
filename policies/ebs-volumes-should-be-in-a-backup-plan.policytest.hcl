# Copyright IBM Corp. 2026

policytest {
  targets = ["ebs-volumes-should-be-in-a-backup-plan.policy.hcl"]
}

resource "aws_backup_selection" "sel_one" {
  skip = true
  attrs = {
    iam_role_arn = "arn:aws:iam::123456789012:role/backup"
    name         = "sel-one"
    plan_id      = "plan-1"
    resources    = ["arn:aws:ec2:us-east-1:123456789012:volume/vol-covered"]
  }
}

resource "aws_backup_selection" "sel_multi" {
  skip = true
  attrs = {
    iam_role_arn = "arn:aws:iam::123456789012:role/backup"
    name         = "sel-multi"
    plan_id      = "plan-2"
    resources = [
      "arn:aws:ec2:us-east-1:123456789012:volume/vol-other",
      "arn:aws:ec2:us-east-1:123456789012:volume/vol-multi",
    ]
  }
}

resource "aws_backup_selection" "sel_empty" {
  skip = true
  attrs = {
    iam_role_arn = "arn:aws:iam::123456789012:role/backup"
    name         = "sel-empty"
    plan_id      = "plan-3"
    resources    = []
  }
}

resource "aws_backup_selection" "sel_null" {
  skip = true
  attrs = {
    iam_role_arn = "arn:aws:iam::123456789012:role/backup"
    name         = "sel-null"
    plan_id      = "plan-4"
    resources    = null
  }
}

# PASS: ARN listed in a selection
resource "aws_ebs_volume" "pass_covered" {
  attrs = {
    availability_zone = "us-east-1a"
    size              = 10
    arn               = "arn:aws:ec2:us-east-1:123456789012:volume/vol-covered"
  }
}

# PASS: ARN is one of several in another selection
resource "aws_ebs_volume" "pass_covered_multi" {
  attrs = {
    availability_zone = "us-east-1a"
    size              = 10
    arn               = "arn:aws:ec2:us-east-1:123456789012:volume/vol-multi"
  }
}

# FAIL: ARN not in any selection
resource "aws_ebs_volume" "fail_not_covered" {
  expect_failure = true
  attrs = {
    availability_zone = "us-east-1a"
    size              = 10
    arn               = "arn:aws:ec2:us-east-1:123456789012:volume/vol-uncovered"
  }
}

# FAIL: arn attribute missing
resource "aws_ebs_volume" "fail_missing_arn" {
  expect_failure = true
  attrs = {
    availability_zone = "us-east-1a"
    size              = 10
  }
}

# FAIL: arn explicitly null (treated as not covered)
resource "aws_ebs_volume" "fail_null_arn" {
  expect_failure = true
  attrs = {
    availability_zone = "us-east-1a"
    size              = 10
    arn               = null
  }
}


