# Copyright IBM Corp. 2026

policytest {
  targets = ["ecs-task-definitions-should-not-use-host-network-mode.policy.hcl"]
}

resource "aws_ecs_task_definition" "fail_host" {
  expect_failure = true
  attrs = {
    family                = "t"
    network_mode          = "host"
    container_definitions = "[{\"name\":\"app\",\"image\":\"nginx\"}]"
  }
}

resource "aws_ecs_task_definition" "pass_bridge" {
  attrs = {
    family                = "t"
    network_mode          = "bridge"
    container_definitions = "[{\"name\":\"app\",\"image\":\"nginx\"}]"
  }
}

resource "aws_ecs_task_definition" "pass_awsvpc" {
  attrs = {
    family                = "t"
    network_mode          = "awsvpc"
    container_definitions = "[{\"name\":\"app\",\"image\":\"nginx\"}]"
  }
}

resource "aws_ecs_task_definition" "pass_none" {
  attrs = {
    family                = "t"
    network_mode          = "none"
    container_definitions = "[{\"name\":\"app\",\"image\":\"nginx\"}]"
  }
}

resource "aws_ecs_task_definition" "pass_missing" {
  attrs = {
    family                = "t"
    container_definitions = "[{\"name\":\"app\",\"image\":\"nginx\"}]"
  }
}

resource "aws_ecs_task_definition" "pass_null" {
  attrs = {
    family                = "t"
    network_mode          = null
    container_definitions = "[{\"name\":\"app\",\"image\":\"nginx\"}]"
  }
}

resource "aws_ecs_task_definition" "pass_uppercase" {
  attrs = {
    family                = "t"
    network_mode          = "HOST"
    container_definitions = "[{\"name\":\"app\",\"image\":\"nginx\"}]"
  }
}


