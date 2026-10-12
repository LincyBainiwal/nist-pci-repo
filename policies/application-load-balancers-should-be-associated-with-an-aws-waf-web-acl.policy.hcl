# Copyright IBM Corp. 2026

# Application Load Balancers should be associated with an AWS WAF web ACL
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.68.0, < 7.0.0"
    }
  }
}

resource_policy "aws_wafv2_web_acl_association" "alb_associated_with_waf_web_acl" {
  locals {
    resource_arn_raw = core::try(attrs.resource_arn, null)
    has_resource_arn = local.resource_arn_raw != null && local.resource_arn_raw != ""
  }

  enforcement_level = "advisory"
  enforce {
    condition     = local.has_resource_arn
    error_message = "aws_wafv2_web_acl_association must set resource_arn to the ARN of an Application Load Balancer (e.g. aws_lb.<name>.arn) so the load balancer is associated with an AWS WAF web ACL."
  }
}


