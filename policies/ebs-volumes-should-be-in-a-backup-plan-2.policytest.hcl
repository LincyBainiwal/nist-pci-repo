# Copyright IBM Corp. 2026

policytest {
  targets = ["ebs-volumes-should-be-in-a-backup-plan.policy.hcl"]
}

# FAIL: no backup selection exists in the configuration
resource "aws_ebs_volume" "fail_no_selection" {
  expect_failure = true
  attrs = {
    availability_zone = "us-east-1a"
    size              = 10
    arn               = "arn:aws:ec2:us-east-1:123456789012:volume/vol-alone"
  }
}


